# TODO: Rename gcs-restore to gcp-restore to align naming schemas
{
  lib,
  writeShellScriptBin,
  google-cloud-sdk,
  gum,
  coreutils,
  gnugrep,
  systemd,
  nix,
  jq,
}:

with lib;

writeShellScriptBin "gcs-restore" ''
      set -euo pipefail

      SERVICE=""
      BUCKET=""
      OLD_HOST=""
      DIR=""
      USER_OWNER=""
      GROUP_OWNER=""
      KEY_FILE=""
      SYSTEMD_SERVICE=""
      DRY_RUN=true
      EXPLICIT_DRY_RUN=false
      DELETE_UNMATCHED=false

      usage() {
        cat <<'EOF'
  gcs-restore - Interactive restore utility for Google Cloud Storage backups

  USAGE:
    gcs-restore [OPTIONS]

  OPTIONS:
    -s, --service <name>   The service name (e.g., 'silverbullet', 'immich', 'frigate')
    -b, --bucket <gs://..> GCS bucket URI
    -o, --old-host <name>  Source hostname of the backup (defaults to current hostname)
    -d, --dir <path>       Local target directory for restoration
    -u, --user <name>      Target owner user for chown
    -g, --group <name>     Target owner group for chown
    -k, --key <path>       Service Account key file path
    --delete               Delete files in target directory that are not present in backup
    -y, --yes, -x,
    --execute,
    --no-dry-run           Execute restoration directly (skip dry-run confirmation prompt)
    -n, --dry-run          Force dry-run mode and exit after displaying execution plan
    -h, --help             Display this help message

  SECURITY & BEHAVIOR:
    - Must be run as root (or via run0) to manage systemd units, write to service dirs, and run chown.
    - Dry-run by default: Shows a summary of files to be updated before applying any changes.
  EOF
      }

      while [[ $# -gt 0 ]]; do
        case "$1" in
          -h|--help)
            usage
            exit 0
            ;;
          -s|--service)
            SERVICE="$2"
            shift 2
            ;;
          -b|--bucket)
            BUCKET="$2"
            shift 2
            ;;
          -o|--old-host)
            OLD_HOST="$2"
            shift 2
            ;;
          -d|--dir)
            DIR="$2"
            shift 2
            ;;
          -u|--user)
            USER_OWNER="$2"
            shift 2
            ;;
          -g|--group)
            GROUP_OWNER="$2"
            shift 2
            ;;
          -k|--key)
            KEY_FILE="$2"
            shift 2
            ;;
          --delete)
            DELETE_UNMATCHED=true
            shift 1
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

      # 1. Verify root privileges
      if [[ $EUID -ne 0 ]]; then
        ${getExe gum} log --level error "This script must be run with root privileges (e.g., using run0 gcs-restore)."
        exit 1
      fi

      ${getExe gum} style \
        --border double \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 212 \
        "GCS BACKUP RESTORE TOOL"

      # Locate flake.nix to evaluate config
      FLAKE_DIR="/home/dom/.dotfiles"
      if [[ ! -d "$FLAKE_DIR" ]]; then
        FLAKE_DIR="$PWD"
      fi

      # Query Nix flake configurations for available hosts
      HOSTS_LIST=""
      if [[ -f "$FLAKE_DIR/flake.nix" ]]; then
        ${getExe gum} log --level info "Loading Nix flake host configurations..."
        HOSTS_LIST="$(${getExe nix} eval --raw "''${FLAKE_DIR}#nixosConfigurations" --apply 'attrs: builtins.concatStringsSep "\n" (builtins.attrNames attrs)' 2>/dev/null || echo "")"
      fi

      CURRENT_HOST="$(${getExe' coreutils "cat"} /etc/hostname 2>/dev/null || hostname 2>/dev/null || echo "")"
      TARGET_HOST=""

      if [[ -n "''${HOSTS_LIST}" ]]; then
        # Convert newline-separated hosts list into a Bash array
        mapfile -t HOSTS_ARR <<< "''${HOSTS_LIST}"

        # Reorder hosts list to place current host at the top (default selection)
        FINAL_HOSTS=()
        if [[ -n "''${CURRENT_HOST}" ]]; then
          for host in "''${HOSTS_ARR[@]}"; do
            if [[ "''${host}" == "''${CURRENT_HOST}" ]]; then
              FINAL_HOSTS+=("''${CURRENT_HOST}")
              break
            fi
          done
        fi

        for host in "''${HOSTS_ARR[@]}"; do
          if [[ "''${host}" != "''${CURRENT_HOST}" ]] && [[ -n "''${host}" ]]; then
            FINAL_HOSTS+=("''${host}")
          fi
        done

        # Pass choices as command-line arguments to keep stdin free for interactive keypresses
        TARGET_HOST="$(${getExe gum} choose "''${FINAL_HOSTS[@]}" --header "Select a host config to load backup definitions from:")"
      fi

      if [[ -z "''${TARGET_HOST}" ]]; then
        TARGET_HOST="''${CURRENT_HOST}"
      fi

      # Query Nix config for backup definitions on the chosen target host
      JOBS_JSON="{}"
      ENABLED_JOBS=""
      if [[ -n "''${TARGET_HOST}" ]] && [[ -f "$FLAKE_DIR/flake.nix" ]]; then
        ${getExe gum} log --level info "Evaluating Nix config backup definitions for \"''${TARGET_HOST}\"..."
        JOBS_JSON="$(${getExe nix} eval --json "''${FLAKE_DIR}#nixosConfigurations.''${TARGET_HOST}.config.services.gcs-backup" 2>/dev/null || echo "{}")"
        if [[ "''${JOBS_JSON}" != "{}" ]]; then
          ENABLED_JOBS="$(echo "''${JOBS_JSON}" | ${getExe jq} -r 'to_entries[] | select(.value.enable == true) | .key' 2>/dev/null || echo "")"
        fi
      fi

      # 2. Interactive Selection if Service is missing
      if [[ -z "''${SERVICE}" ]]; then
        if [[ -n "''${ENABLED_JOBS}" ]]; then
          ${getExe gum} log --level info "Select from configured backup services on \"''${TARGET_HOST}\":"
          # We also offer 'custom' in case they want a non-declarative restore
          SERVICE="$(${getExe gum} choose $ENABLED_JOBS "custom" --header "Select service to restore:")"
        else
          SERVICE="$(${getExe gum} input --placeholder "e.g., silverbullet (or 'custom')" --header "Enter the service name to restore:")"
        fi
      fi

      if [[ -z "''${SERVICE}" ]]; then
        ${getExe gum} log --level error "Service selection is required."
        exit 1
      fi

      # Extract defaults from Nix config if available
      NIX_BUCKET=""
      NIX_DIR=""
      NIX_KEY_FILE=""
      NIX_SYSTEMD=""

      if [[ -n "''${TARGET_HOST}" ]] && [[ -n "''${SERVICE}" ]] && [[ "''${SERVICE}" != "custom" ]]; then
        JOB_CONF=$(echo "''${JOBS_JSON}" | ${getExe jq} -r ".[\"''${SERVICE}\"]" 2>/dev/null || echo "null")
        if [[ "''${JOB_CONF}" != "null" ]]; then
          NIX_BUCKET=$(echo "''${JOB_CONF}" | ${getExe jq} -r '.bucket' 2>/dev/null || echo "")
          NIX_DIRS=$(echo "''${JOB_CONF}" | ${getExe jq} -r '.directories[]' 2>/dev/null || echo "")
          NIX_DIR=$(echo "''${NIX_DIRS}" | head -n1 || echo "")
          NIX_KEY_FILE=$(echo "''${JOB_CONF}" | ${getExe jq} -r '.serviceAccountKeyFile' 2>/dev/null || echo "")
          
          WANTED_BY=$(echo "''${JOB_CONF}" | ${getExe jq} -r '.wantedBy[]' 2>/dev/null || echo "")
          WANTS=$(echo "''${JOB_CONF}" | ${getExe jq} -r '.wants[]' 2>/dev/null || echo "")
          NIX_SYSTEMD=$(echo -e "''${WANTED_BY}\n''${WANTS}" | grep "\.service$" | head -n1 || echo "")
          if [[ -z "''${NIX_SYSTEMD}" ]]; then
            NIX_SYSTEMD="''${SERVICE}.service"
          fi
        fi
      fi

      # Determine default configs based on service/Nix config
      DEFAULT_BUCKET="''${NIX_BUCKET}"
      DEFAULT_DIR="''${NIX_DIR}"
      DEFAULT_USER=""
      DEFAULT_GROUP=""
      DEFAULT_SYSTEMD="''${NIX_SYSTEMD}"

      if [[ -n "''${SERVICE}" ]] && [[ "''${SERVICE}" != "custom" ]]; then
        DEFAULT_USER="''${SERVICE}"
        DEFAULT_GROUP="''${SERVICE}"
      else
        DEFAULT_USER="root"
        DEFAULT_GROUP="root"
      fi

      if [[ -z "''${DEFAULT_SYSTEMD}" ]]; then
        if [[ -n "''${SERVICE}" ]] && [[ "''${SERVICE}" != "custom" ]]; then
          DEFAULT_SYSTEMD="''${SERVICE}.service"
        fi
      fi

      # Prompt for variables if not provided as options
      if [[ -z "''${BUCKET}" ]]; then
        if [[ -n "''${DEFAULT_BUCKET}" ]]; then
          BUCKET="$(${getExe gum} input --value "''${DEFAULT_BUCKET}" --header "Enter GCS Bucket URI:")"
        else
          BUCKET="$(${getExe gum} input --placeholder "gs://my-backup-bucket" --header "Enter GCS Bucket URI:")"
        fi
      fi

      if [[ -z "''${BUCKET}" ]]; then
        ${getExe gum} log --level error "GCS Bucket URI is required."
        exit 1
      fi

      # Setup Google Cloud Auth
      if [[ -z "''${KEY_FILE}" ]]; then
        if [[ -n "''${NIX_KEY_FILE}" ]]; then
          KEY_FILE="''${NIX_KEY_FILE}"
        elif [[ -n "''${SERVICE}" ]]; then
          KEY_FILE="/run/secrets/services/''${SERVICE}/gcs-backup-key"
        fi
      fi

      if [[ ! -f "''${KEY_FILE}" ]]; then
        KEY_FILE="$(${getExe gum} input --placeholder "/run/secrets/services/..." --header "Enter GCS Service Account JSON key path:")"
      fi

      if [[ ! -f "''${KEY_FILE}" ]]; then
        ${getExe gum} log --level error "GCS Service Account JSON key file not found at: ''${KEY_FILE}"
        exit 1
      fi

      ${getExe gum} log --level info "Authenticating gcloud service account..."
      export CLOUDSDK_CONFIG="/var/lib/gcs-backup/restore-''${SERVICE:-custom}"
      mkdir -p "''${CLOUDSDK_CONFIG}"
      ${getExe google-cloud-sdk} auth activate-service-account --key-file="''${KEY_FILE}" >/dev/null 2>&1 || {
        ${getExe gum} log --level error "Failed to authenticate using key file: ''${KEY_FILE}"
        exit 1
      }

      # Query GCS for available hostnames
      if [[ -z "''${OLD_HOST}" ]]; then
        ${getExe gum} log --level info "Querying GCS bucket for backed-up hostnames..."
        HOSTS_IN_BUCKET="$(${getExe google-cloud-sdk} storage ls "''${BUCKET}/" 2>/dev/null | ${getExe gnugrep} -oE '[^/]+/$' | tr -d '/' || true)"

        if [[ -n "''${HOSTS_IN_BUCKET}" ]]; then
          OLD_HOST="$(${getExe gum} choose ''${HOSTS_IN_BUCKET} --header "Select the SOURCE host of the backup:")"
        else
          OLD_HOST="$(${getExe gum} input --value "''${CURRENT_HOST}" --header "Enter SOURCE hostname of the backup:")"
        fi
      fi

      if [[ -z "''${OLD_HOST}" ]]; then
        ${getExe gum} log --level error "Source hostname is required."
        exit 1
      fi

      # Prompt for destination folder, ownership, and systemd service
      if [[ -z "''${DIR}" ]]; then
        if [[ -n "''${DEFAULT_DIR}" ]]; then
          DIR="$(${getExe gum} input --value "''${DEFAULT_DIR}" --header "Enter target local directory for restoration:")"
        else
          DIR="$(${getExe gum} input --placeholder "/var/lib/my-service" --header "Enter target local directory for restoration:")"
        fi
      fi

      if [[ -z "''${DIR}" ]]; then
        ${getExe gum} log --level error "Local destination directory is required."
        exit 1
      fi

      if [[ -z "''${USER_OWNER}" ]]; then
        USER_OWNER="$(${getExe gum} input --value "''${DEFAULT_USER}" --header "Enter local target owner user:")"
      fi

      if [[ -z "''${GROUP_OWNER}" ]]; then
        GROUP_OWNER="$(${getExe gum} input --value "''${DEFAULT_GROUP}" --header "Enter local target owner group:")"
      fi

      if [[ -z "''${SYSTEMD_SERVICE}" ]]; then
        if [[ -n "''${DEFAULT_SYSTEMD}" ]]; then
          SYSTEMD_SERVICE="$(${getExe gum} input --value "''${DEFAULT_SYSTEMD}" --header "Enter systemd service unit to stop/start (leave empty to skip):")"
        else
          SYSTEMD_SERVICE="$(${getExe gum} input --placeholder "e.g., silverbullet.service" --header "Enter systemd service unit to stop/start (leave empty to skip):")"
        fi
      fi

      # Construct source GCS path
      JOB_NAME="''${SERVICE:-}"
      if [[ -z "''${JOB_NAME}" ]] || [[ "''${JOB_NAME}" == "custom" ]]; then
        JOB_NAME="$(${getExe gum} input --placeholder "e.g., silverbullet" --header "Enter the backup job name:")"
      fi

      # Replicate GCS path schema: gs://<bucket>/<hostname>/<job-name><dir>
      GCS_PATH="''${BUCKET}/''${OLD_HOST}/''${JOB_NAME}''${DIR}"

      # Summary and Confirmation
      SUMMARY="Restoration Plan Summary:
      - GCS Source Path:   ''${GCS_PATH}
      - Local Target Dir:  ''${DIR}
      - File Ownership:    ''${USER_OWNER}:''${GROUP_OWNER}
      - Systemd Service:   ''${SYSTEMD_SERVICE:-None}
      - Delete Unmatched:  ''${DELETE_UNMATCHED}"

      ${getExe gum} style \
        --border rounded \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 214 \
        "RESTORATION PLAN" \
        "''${SUMMARY}"

      if [[ "''${DRY_RUN}" = true ]] && [[ "''${EXPLICIT_DRY_RUN}" = true ]]; then
        ${getExe gum} log --level info "Dry-run mode explicit. Exiting."
        exit 0
      fi

      if [[ "''${DRY_RUN}" = true ]]; then
        if ! ${getExe gum} confirm "Proceed with restoration dry-run?"; then
          ${getExe gum} log --level warn "Restoration cancelled by user."
          exit 0
        fi
      fi

      # 3. Execution Phase
      # Step A: Stop the service if running
      if [[ -n "''${SYSTEMD_SERVICE}" ]]; then
        if ${systemd}/bin/systemctl is-active --quiet "''${SYSTEMD_SERVICE}" 2>/dev/null; then
          ${getExe gum} log --level info "Stopping service: ''${SYSTEMD_SERVICE}..."
          ${systemd}/bin/systemctl stop "''${SYSTEMD_SERVICE}"
        fi
      fi

      # Step B: Dry run rsync if applicable
      RSYNC_FLAGS=("-r")
      if [[ "''${DELETE_UNMATCHED}" = true ]]; then
        RSYNC_FLAGS+=("--delete-unmatched-destination-objects")
      fi

      if [[ "''${DRY_RUN}" = true ]]; then
        ${getExe gum} log --level info "Running gcloud storage rsync in DRY RUN mode..."
        # -n makes it dry-run
        if ! ${getExe google-cloud-sdk} storage rsync "''${RSYNC_FLAGS[@]}" -n "''${GCS_PATH}" "''${DIR}"; then
          ${getExe gum} log --level error "GCS rsync dry-run failed."
          exit 1
        fi

        if ! ${getExe gum} confirm "Are you satisfied with the dry-run output? Ready to write data to disk?"; then
          ${getExe gum} log --level warn "Restoration cancelled. Starting service back up if it was stopped..."
          if [[ -n "''${SYSTEMD_SERVICE}" ]]; then
            ${systemd}/bin/systemctl start "''${SYSTEMD_SERVICE}"
          fi
          exit 0
        fi
      fi

      # Step C: Real Restore Sync
      ${getExe gum} log --level info "Performing actual restoration sync from GCS..."
      # Ensure target directory exists
      mkdir -p "''${DIR}"
      if ! ${getExe google-cloud-sdk} storage rsync "''${RSYNC_FLAGS[@]}" "''${GCS_PATH}" "''${DIR}"; then
        ${getExe gum} log --level error "Restoration sync failed!"
        exit 1
      fi

      # Step D: Apply file ownership permissions
      if [[ -n "''${USER_OWNER}" ]] || [[ -n "''${GROUP_OWNER}" ]]; then
        ${getExe gum} log --level info "Applying local file ownership permissions (''${USER_OWNER}:''${GROUP_OWNER})..."
        chown -R "''${USER_OWNER}:''${GROUP_OWNER}" "''${DIR}"
      fi

      # Step E: Restart the service
      if [[ -n "''${SYSTEMD_SERVICE}" ]]; then
        ${getExe gum} log --level info "Starting service: ''${SYSTEMD_SERVICE}..."
        ${systemd}/bin/systemctl start "''${SYSTEMD_SERVICE}"
        ${getExe gum} log --level info "Showing active logs (press Ctrl+C to exit):"
        ${systemd}/bin/systemctl status "''${SYSTEMD_SERVICE}" --no-pager || true
      fi

      ${getExe gum} style \
        --foreground 46 \
        --bold \
        "Restoration completed successfully!"
''
