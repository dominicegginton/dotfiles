{
  lib,
  writeShellScriptBin,
  google-cloud-sdk,
  gnupg,
  gum,
  coreutils,
  gnugrep,
  gawk,
}:

with lib;

writeShellScriptBin "gpg-import-bucket" ''
    set -euo pipefail

    BUCKET="''${GPG_BUCKET_URI:-}"
    KEY_PATH=""
    TRUST_LEVEL=""
    DRY_RUN=true
    EXPLICIT_DRY_RUN=false

    usage() {
      cat <<'EOF'
  gpg-import-bucket - Select and import GPG keys from cloud storage

  USAGE:
    gpg-import-bucket [OPTIONS]

  OPTIONS:
    -b, --bucket <uri>     Cloud storage bucket URI (default: $GPG_BUCKET_URI)
    -k, --key <path>       Specific key object path or URI (skips object selection)
    -t, --trust <level>    Set trust level for imported key ('ultimate', 'full', 'marginal', 'none')
    -y, --yes, -x,
    --execute,
    --no-dry-run           Execute import directly (skip dry-run confirmation prompt)
    -n, --dry-run           Force dry-run mode and exit after displaying execution plan
    -h, --help             Display this help message

  SECURITY & BEHAVIOR:
    - Dry-run by default: Shows a summary of key import actions before making changes.
    - Whitelisted filtering: Only valid GPG key extensions (.asc, .gpg, .pgp, .key) are processed.
    - Privacy aware: No hardcoded secrets, bucket URIs, or personal names in script logic.
  EOF
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -b|--bucket)
          BUCKET="$2"
          shift 2
          ;;
        -k|--key)
          KEY_PATH="$2"
          shift 2
          ;;
        -t|--trust)
          TRUST_LEVEL="$2"
          shift 2
          ;;
        -y|--yes|-x|--execute|--no-dry-run)
          DRY_RUN=false
          shift 1
          ;;
        -n|--dry-run)
          DRY_RUN=true
          EXPLICIT_DRY_RUN=true
          shift 1
          ;;
        -*)
          ${getExe gum} log --level error "Unknown option: $1"
          usage
          exit 1
          ;;
        *)
          ${getExe gum} log --level error "Unexpected argument: $1"
          usage
          exit 1
          ;;
      esac
    done

    ${getExe gum} style \
      --border double \
      --margin "1 0" \
      --padding "1 2" \
      --border-foreground 212 \
      "GPG CLOUD KEY IMPORTER"

    # 1. Verify cloud authentication
    ${getExe gum} log --level info "1. Verifying cloud storage authentication..."
    if ! ${getExe google-cloud-sdk} auth print-access-token >/dev/null 2>&1; then
      ${getExe gum} log --level warn "No active cloud authentication session found."
      if [[ "''${DRY_RUN}" = false ]] || ${getExe gum} confirm "Run authentication workflow?"; then
        ${getExe google-cloud-sdk} auth login
      else
        ${getExe gum} log --level error "Authentication is required to access cloud storage."
        exit 1
      fi
    fi

    # 2. Whitelisted object scanning
    if [[ -z "''${BUCKET}" ]] && [[ -z "''${KEY_PATH}" ]]; then
      BUCKET="$(${getExe gum} input --placeholder "gs://my-gpg-bucket" --header "Enter Cloud Storage Bucket URI:")"
      if [[ -z "''${BUCKET}" ]]; then
        ${getExe gum} log --level error "Bucket URI is required."
        exit 1
      fi
    fi

    SELECTED_KEYS=()
    if [[ -n "''${KEY_PATH}" ]]; then
      if [[ "''${KEY_PATH}" == gs://* ]]; then
        SELECTED_KEYS+=("''${KEY_PATH}")
      else
        SELECTED_KEYS+=("''${BUCKET}/''${KEY_PATH#/#}")
      fi
    else
      ${getExe gum} log --level info "2. Querying cloud storage for whitelisted GPG key objects..."
      RAW_FILES="$(${getExe google-cloud-sdk} storage ls "''${BUCKET}/**" 2>/dev/null || true)"
      
      # Deep whitelisting: restrict strictly to valid OpenPGP key extensions (.asc, .gpg, .pgp, .key)
      WHITELISTED_KEYS="$(echo "''${RAW_FILES}" | ${getExe gnugrep} -E '^gs://.+\.(asc|gpg|pgp|key)$' | ${getExe' coreutils "sort"} -u || true)"

      if [[ -z "''${WHITELISTED_KEYS}" ]]; then
        ${getExe gum} log --level error "No whitelisted GPG key objects (.asc, .gpg, .pgp, .key) found in bucket."
        exit 1
      fi

      CHOICE="$(${getExe gum} choose --no-limit --header "Select key object(s) to import (SPACE to toggle, ENTER to confirm):" <<< "''${WHITELISTED_KEYS}")"

      if [[ -z "''${CHOICE}" ]]; then
        ${getExe gum} log --level warn "No key objects selected. Aborting."
        exit 0
      fi

      while IFS= read -r line; do
        if [[ -n "''${line}" ]]; then
          SELECTED_KEYS+=("''${line}")
        fi
      done <<< "''${CHOICE}"
    fi

    # 3. Interactive Trust Selection if not provided
    if [[ -z "''${TRUST_LEVEL}" ]]; then
      if ${getExe gum} confirm "Configure owner trust level for imported key(s)?"; then
        TRUST_LEVEL="$(${getExe gum} choose "ultimate" "full" "marginal" "none" --header "Select trust level to assign:")"
      else
        TRUST_LEVEL="none"
      fi
    fi

    # 4. Dry Run Mode
    if [[ "''${DRY_RUN}" = true ]]; then
      SUMMARY="Selected Key Objects:\n"
      for KEY_URI in "''${SELECTED_KEYS[@]}"; do
        SUMMARY+="  - ''${KEY_URI}\n"
      done
      SUMMARY+="\nConfigured Trust Level: ''${TRUST_LEVEL:-none}\n"
      SUMMARY+="Target Keyring: ~/.gnupg/pubring.kbx"

      ${getExe gum} style \
        --border rounded \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 214 \
        "DRY RUN MODE SUMMARY (No keyring changes made)" \
        "''${SUMMARY}"

      if [[ "''${EXPLICIT_DRY_RUN}" = true ]]; then
        ${getExe gum} log --level info "Dry-run mode explicit. Exiting without making changes."
        exit 0
      fi

      if ! ${getExe gum} confirm "Proceed with downloading and importing selected key(s)?"; then
        ${getExe gum} log --level warn "Import cancelled by user."
        exit 0
      fi
    fi

    # 5. Execution - Fetch and Import
    ${getExe gum} log --level info "3. Downloading and importing key(s)..."

    for KEY_URI in "''${SELECTED_KEYS[@]}"; do
      ${getExe gum} log --level info "Importing key object..."
      IMPORT_OUTPUT="$(${getExe google-cloud-sdk} storage cat "''${KEY_URI}" | ${getExe gnupg} --import 2>&1 || true)"
      echo "''${IMPORT_OUTPUT}" | ${getExe gum} log --level info
    done

    # 6. Apply Trust
    if [[ -n "''${TRUST_LEVEL}" ]] && [[ "''${TRUST_LEVEL}" != "none" ]]; then
      TRUST_CODE=""
      case "''${TRUST_LEVEL}" in
        ultimate) TRUST_CODE="6" ;;
        full)     TRUST_CODE="5" ;;
        marginal) TRUST_CODE="4" ;;
        *)
          ${getExe gum} log --level error "Invalid trust level: ''${TRUST_LEVEL}"
          exit 1
          ;;
      esac

      SECRET_KEYS="$(${getExe gnupg} --list-secret-keys --with-colons 2>/dev/null | ${getExe gawk} -F: '
        $1 == "sec" { sec=$5 }
        $1 == "fpr" { fpr=$10 }
        $1 == "uid" { print fpr " (" $10 ")" }
      ' | ${getExe' coreutils "sort"} -u || true)"

      if [[ -n "''${SECRET_KEYS}" ]]; then
        TRUST_CHOICES="$(${getExe gum} choose --no-limit --header "Select key(s) to apply ''${TRUST_LEVEL} trust (SPACE to toggle, ENTER to confirm):" <<< "''${SECRET_KEYS}")"

        if [[ -n "''${TRUST_CHOICES}" ]]; then
          while IFS= read -r line; do
            if [[ -n "''${line}" ]]; then
              FPR="$(echo "''${line}" | ${getExe gawk} '{print $1}')"
              echo "''${FPR}:''${TRUST_CODE}:" | ${getExe gnupg} --import-ownertrust
              ${getExe gum} log --level info "Set trust level ''${TRUST_LEVEL} for key."
            fi
          done <<< "''${TRUST_CHOICES}"
        fi
      fi
    fi

    ${getExe gum} style --foreground 2 "GPG Key Import Complete!"
    ${getExe gnupg} --list-secret-keys
''
