{
  lib,
  writeShellScriptBin,
  nix,
  caligula,
  gum,
  coreutils,
  findutils,
}:

with lib;

writeShellScriptBin "burn-infector" ''
    set -euo pipefail

    SHOW_HELP=false
    SKIP_BUILD=false
    DRY_RUN=true
    EXPLICIT_DRY_RUN=false
    TARGET_DEVICE=""

    usage() {
      cat <<'EOF'
  burn-infector - Build and burn the NixOS Infector live ISO image using Caligula

  USAGE:
    burn-infector [OPTIONS]

  OPTIONS:
    -s, --skip-build        Skip rebuilding .#infector-iso and use existing ./result ISO
    -d, --device <path>     Specify target block device (e.g. /dev/sdb or /dev/disk/by-id/...)
    -y, --yes, --execute    Execute build and burn directly (skip dry-run confirmation)
    -n, --dry-run           Force dry-run mode without execution prompt
    -h, --help              Display this help message

  DESCRIPTION:
    This script builds the unattended live ISO installer configuration (.#infector-iso)
    and uses Caligula (a TUI disk imager) to safely burn the resulting ISO onto a USB flash drive.
    By default, a dry-run summary is shown before asking for confirmation to execute.
  EOF
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -s|--skip-build)
          SKIP_BUILD=true
          shift 1
          ;;
        -d|--device)
          TARGET_DEVICE="$2"
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
          ${getExe gum} log --level error "Unknown option $1"
          usage
          exit 1
          ;;
        *)
          ${getExe gum} log --level error "Unexpected argument $1"
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
      "NIXOS INFECTOR ISO BURNER (Caligula)"

    # Handle Dry Run
    if [[ "''${DRY_RUN}" = true ]]; then
      DISPLAY_ISO=""
      if [[ -d "./result" ]]; then
        DISPLAY_ISO="''$(${getExe' findutils "find"} -L ./result -name "*.iso" -type f | ${getExe' coreutils "head"} -n1 || echo "")"
      fi
      if [[ -z "''${DISPLAY_ISO}" ]]; then
        DISPLAY_ISO="./result/iso/*.iso"
      fi

      DRY_BURN_CMD=("${getExe caligula}" "burn" "''${DISPLAY_ISO}")
      if [[ -n "''${TARGET_DEVICE}" ]]; then
        DRY_BURN_CMD+=("--target" "''${TARGET_DEVICE}")
      fi

      BUILD_MSG="nix build .#infector-iso"
      if [[ "''${SKIP_BUILD}" = true ]]; then
        BUILD_MSG="[Skipped via --skip-build]"
      fi

      ${getExe gum} style \
        --border normal \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 214 \
        "DRY RUN SUMMARY

    Build Action:   ''${BUILD_MSG}
    ISO Image:      ''${DISPLAY_ISO}
    Target Device:  ''${TARGET_DEVICE:-Interactive selection in Caligula TUI}

  Command that WOULD be executed:
    ''${DRY_BURN_CMD[*]}"

      if [[ "''${EXPLICIT_DRY_RUN}" = false ]] && [ -t 0 ]; then
        if ${getExe gum} confirm "Proceed to build and burn ISO now?"; then
          DRY_RUN=false
        fi
      fi

      if [[ "''${DRY_RUN}" = true ]]; then
        ${getExe gum} log --level info "Dry run completed. Pass -y or --execute to run directly."
        exit 0
      fi
    fi

    # Execution phase
    if [[ "''${SKIP_BUILD}" = false ]]; then
      ${getExe gum} log --level info "Building .#infector-iso NixOS live installer..."
      ${getExe nix} build .#infector-iso
    else
      ${getExe gum} log --level info "Skipping build (--skip-build set)."
    fi

    ISO_PATH=""
    if [[ -d "./result" ]]; then
      ISO_PATH="''$(${getExe' findutils "find"} -L ./result -name "*.iso" -type f | ${getExe' coreutils "head"} -n1 || echo "")"
    fi

    if [[ -z "''${ISO_PATH}" ]] || [[ ! -f "''${ISO_PATH}" ]]; then
      ${getExe gum} log --level error "Could not locate built .iso image under ./result. Ensure 'nix build .#infector-iso' succeeds."
      exit 1
    fi

    ${getExe gum} log --level info "Located installer ISO: ''${ISO_PATH}"

    BURN_CMD=("${getExe caligula}" "burn" "''${ISO_PATH}")
    if [[ -n "''${TARGET_DEVICE}" ]]; then
      BURN_CMD+=("--target" "''${TARGET_DEVICE}")
    fi

    ${getExe gum} log --level info "Launching Caligula disk imager..."
    echo ""

    exec "''${BURN_CMD[@]}"
''
