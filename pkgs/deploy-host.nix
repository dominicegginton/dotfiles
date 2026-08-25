{
  lib,
  writeShellScriptBin,
  nix,
  nixos-anywhere,
  gnupg,
  openssh,
  ssh-to-age,
  gum,
}:

with lib;

writeShellScriptBin "deploy-host" ''
    set -euo pipefail

    SHOW_HELP=false
    MODE=""
    SSH_KEY_PATH=""
    COPY_HOST_KEYS=false
    GENERATE_HWCONFIG=false
    VM_TEST=false
    DEBUG=false
    DRY_RUN=false
    HOSTNAME=""
    TARGET=""

    usage() {
      cat <<'EOF'
  deploy-host - Deploy a new machine or reinstall an existing machine remotely using nixos-anywhere

  USAGE:
    deploy-host [OPTIONS] [HOSTNAME] [TARGET]

  ARGUMENTS:
    [HOSTNAME]              Flake host configuration name (e.g. ghost-gs60, latitude-7390)
    [TARGET]                Remote target SSH destination (e.g. root@192.168.1.50)

  OPTIONS:
    -m, --mode <mode>       Deployment mode: 'reinstall' (existing host) or 'new' (fresh machine)
    -k, --ssh-key <path>    Path to local host SSH private key (/etc/ssh/ssh_host_ed25519_key)
    -c, --copy-host-keys    Copy existing host SSH keys from remote target (default for reinstall)
    -g, --generate-hwconfig Generate hardware config on target and save to hosts/<hostname>-hardware.nix
    -t, --vm-test           Test build & disko partitioning inside a local QEMU VM
    -d, --debug             Enable verbose debug mode for nixos-anywhere
    -n, --dry-run           Perform dry run inspection without executing nixos-anywhere
    -h, --help              Display this help message

  KEY & SECRET CONSIDERATIONS:
    1. sops-nix:
       Target host needs its /etc/ssh/ssh_host_ed25519_key on boot to decrypt secrets.
       In impermanence setups (/persist), keys must also be in /persist/etc/ssh/.
       The age public key (derived via ssh-to-age) MUST match .sops.yaml creation_rules.

    2. GPG / YubiKey:
       Local GPG agent & YubiKey smartcard provide SSH keys & decrypt sops files.
       Ensure GPG_TTY and SSH_AUTH_SOCK are active before running.

    3. Root & User Access:
       Modules harden SSH by setting PermitRootLogin=no.
       Post-installation access is via user 'dom' with SSH keys, using 'run0' for elevated privileges.
  EOF
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        -m|--mode)
          MODE="$2"
          shift 2
          ;;
        -k|--ssh-key)
          SSH_KEY_PATH="$2"
          shift 2
          ;;
        -c|--copy-host-keys)
          COPY_HOST_KEYS=true
          shift 1
          ;;
        -g|--generate-hwconfig)
          GENERATE_HWCONFIG=true
          shift 1
          ;;
        -t|--vm-test)
          VM_TEST=true
          shift 1
          ;;
        -d|--debug)
          DEBUG=true
          shift 1
          ;;
        -n|--dry-run)
          DRY_RUN=true
          shift 1
          ;;
        -*)
          ${getExe gum} log --level error "Unknown option $1"
          usage
          exit 1
          ;;
        *)
          if [[ -z "''${HOSTNAME}" ]]; then
            HOSTNAME="$1"
          elif [[ -z "''${TARGET}" ]]; then
            TARGET="$1"
          else
            ${getExe gum} log --level error "Unexpected argument $1"
            exit 1
          fi
          shift 1
          ;;
      esac
    done

    # Interactive selection for Hostname if missing using gum filter
    if [[ -z "''${HOSTNAME}" ]]; then
      ${getExe gum} log --level info "No host specified. Select host configuration from flake:"
      HOSTS_LIST="''$(${getExe nix} eval .#nixosConfigurations --apply 'builtins.attrNames' --json 2>/dev/null | ${getExe nix} run nixpkgs#jq -- -r '.[]' 2>/dev/null || echo "")"
      if [[ -n "''${HOSTS_LIST}" ]]; then
        HOSTNAME="''$(echo "''${HOSTS_LIST}" | ${getExe gum} filter --header "Select host configuration to deploy")"
      else
        HOSTNAME="''$(${getExe gum} input --placeholder "Enter host configuration name (e.g. ghost-gs60)")"
      fi

      if [[ -z "''${HOSTNAME}" ]]; then
        ${getExe gum} log --level error "Host configuration name is required."
        exit 1
      fi
    fi

    # Interactive input for Target if missing and not VM testing
    if [[ -z "''${TARGET}" ]] && [[ "''${VM_TEST}" = false ]]; then
      TARGET="''$(${getExe gum} input --placeholder "root@<ip-or-domain>" --header "Enter remote target SSH destination")"
      if [[ -z "''${TARGET}" ]]; then
        ${getExe gum} log --level error "Target SSH destination is required."
        exit 1
      fi
    fi

    ${getExe gum} log --level info "1. Setting up GPG / YubiKey & SSH Environment..."
    export GPG_TTY="''$(tty 2>/dev/null || echo '/dev/tty')"
    if command -v ${gnupg}/bin/gpgconf >/dev/null 2>&1; then
      ${gnupg}/bin/gpgconf --launch gpg-agent 2>/dev/null || true
      GPG_SSH_SOCK="''$(${gnupg}/bin/gpgconf --list-dirs agent-ssh-socket 2>/dev/null || true)"
      if [[ -n "''${GPG_SSH_SOCK}" ]] && [[ -S "''${GPG_SSH_SOCK}" ]] && [[ -z "''${SSH_AUTH_SOCK:-}" ]]; then
        export SSH_AUTH_SOCK="''${GPG_SSH_SOCK}"
        ${getExe gum} log --level info "Set SSH_AUTH_SOCK to GPG agent (''${GPG_SSH_SOCK})"
      fi
    fi

    if ${gnupg}/bin/gpg --card-status >/dev/null 2>&1; then
      ${getExe gum} log --level info "YubiKey / Smartcard detected and active."
    else
      ${getExe gum} log --level warn "No YubiKey / Smartcard detected. Continuing with available SSH identities..."
    fi

    ${getExe gum} log --level info "2. Validating host configuration '.#nixosConfigurations.''${HOSTNAME}'..."
    if ! ${getExe nix} eval ".#nixosConfigurations.''${HOSTNAME}.config.system.build.toplevel.drvPath" >/dev/null 2>&1; then
      ${getExe gum} log --level error "Host \"''${HOSTNAME}\" is not defined under nixosConfigurations in flake.nix!"
      exit 1
    fi

    # Determine mode if not specified
    if [[ -z "''${MODE}" ]]; then
      if [[ -f .sops.yaml ]] && grep -q "''${HOSTNAME}" .sops.yaml 2>/dev/null; then
        MODE="reinstall"
      else
        MODE="new"
      fi
    fi

    if [[ "''${MODE}" == "reinstall" ]] && [[ -z "''${SSH_KEY_PATH}" ]] && [[ "''${COPY_HOST_KEYS}" = false ]]; then
      COPY_HOST_KEYS=true
    fi

    ${getExe gum} log --level info "Deployment Mode: ''${MODE}"

    # Setup temporary directory for extra-files
    TEMP_DIR="''$(mktemp -d)"
    trap 'rm -rf "''${TEMP_DIR}"' EXIT

    EXTRA_FILES="''${TEMP_DIR}/extra-files"
    mkdir -p "''${EXTRA_FILES}/etc/ssh" "''${EXTRA_FILES}/persist/etc/ssh"

    # Stage YubiKey PAM U2F mappings if present on deploying machine
    U2F_KEYS_FILE="''${HOME:-/home/dom}/.config/Yubico/u2f_keys"
    if [[ -f "''${U2F_KEYS_FILE}" ]]; then
      mkdir -p "''${EXTRA_FILES}/home/dom/.config/Yubico" "''${EXTRA_FILES}/persist/home/dom/.config/Yubico"
      cp "''${U2F_KEYS_FILE}" "''${EXTRA_FILES}/home/dom/.config/Yubico/u2f_keys"
      cp "''${U2F_KEYS_FILE}" "''${EXTRA_FILES}/persist/home/dom/.config/Yubico/u2f_keys"
      chmod 700 "''${EXTRA_FILES}/home/dom/.config/Yubico" "''${EXTRA_FILES}/persist/home/dom/.config/Yubico"
      chmod 600 "''${EXTRA_FILES}/home/dom/.config/Yubico/u2f_keys" "''${EXTRA_FILES}/persist/home/dom/.config/Yubico/u2f_keys"
      ${getExe gum} log --level info "Staged YubiKey PAM U2F keys (~/.config/Yubico/u2f_keys)"
    fi

    # Stage NetworkManager Wi-Fi/Ethernet system connections if present on deploying machine
    NM_CONNS_DIR=""
    if [[ -d "/persist/etc/NetworkManager/system-connections" ]] && [[ -n "$(${pkgs.coreutils}/bin/ls -A /persist/etc/NetworkManager/system-connections 2>/dev/null)" ]]; then
      NM_CONNS_DIR="/persist/etc/NetworkManager/system-connections"
    elif [[ -d "/etc/NetworkManager/system-connections" ]] && [[ -n "$(${pkgs.coreutils}/bin/ls -A /etc/NetworkManager/system-connections 2>/dev/null)" ]]; then
      NM_CONNS_DIR="/etc/NetworkManager/system-connections"
    fi

    if [[ -n "''${NM_CONNS_DIR}" ]]; then
      mkdir -p "''${EXTRA_FILES}/etc/NetworkManager/system-connections" "''${EXTRA_FILES}/persist/etc/NetworkManager/system-connections"
      cp -a "''${NM_CONNS_DIR}/"* "''${EXTRA_FILES}/etc/NetworkManager/system-connections/" 2>/dev/null || true
      cp -a "''${NM_CONNS_DIR}/"* "''${EXTRA_FILES}/persist/etc/NetworkManager/system-connections/" 2>/dev/null || true
      chmod -R 600 "''${EXTRA_FILES}/etc/NetworkManager/system-connections/" "''${EXTRA_FILES}/persist/etc/NetworkManager/system-connections/"
      ${getExe gum} log --level info "Staged NetworkManager system connections (from ''${NM_CONNS_DIR})"
    fi

    # Check host SOPS secret configuration
    HOST_SOPS_FILE="secrets/hosts/''${HOSTNAME}.yaml"
    if [[ -f "''${HOST_SOPS_FILE}" ]]; then
      ${getExe gum} log --level info "Found host-specific SOPS secrets file: ''${HOST_SOPS_FILE}"
    else
      ${getExe gum} log --level info "No host-specific SOPS file found at ''${HOST_SOPS_FILE} (using global secrets)"
    fi

    ${getExe gum} log --level info "3. Managing Host SSH Keys & SOPS Secrets..."

    if [[ -n "''${SSH_KEY_PATH}" ]]; then
      if [[ ! -f "''${SSH_KEY_PATH}" ]]; then
        ${getExe gum} log --level error "SSH key file \"''${SSH_KEY_PATH}\" does not exist!"
        exit 1
      fi
      ${getExe gum} log --level info "Using provided host key: ''${SSH_KEY_PATH}"
      cp "''${SSH_KEY_PATH}" "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key"
      cp "''${SSH_KEY_PATH}" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key"
      chmod 600 "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key"

      if [[ -f "''${SSH_KEY_PATH}.pub" ]]; then
        cp "''${SSH_KEY_PATH}.pub" "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub"
        cp "''${SSH_KEY_PATH}.pub" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key.pub"
      else
        ${openssh}/bin/ssh-keygen -y -f "''${SSH_KEY_PATH}" > "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub"
        cp "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key.pub"
      fi
      chmod 644 "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key.pub"

      DERIVED_AGE="''$(${getExe ssh-to-age} -i "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub")"
      ${getExe gum} log --level info "Derived Host Age Public Key: ''${DERIVED_AGE}"

      if [[ -f .sops.yaml ]] && grep -q "''${DERIVED_AGE}" .sops.yaml 2>/dev/null; then
        ${getExe gum} log --level info "Verified: Host Age Key matches .sops.yaml."
      else
        ${getExe gum} log --level warn "Host Age Key ''${DERIVED_AGE} was NOT found in .sops.yaml!"
        ${getExe gum} log --level warn "sops-nix will fail to decrypt secrets on target host if .sops.yaml does not match!"
        if ! ${getExe gum} confirm "Host Age key mismatch. Do you want to proceed anyway?"; then
          ${getExe gum} log --level error "Aborting deployment."
          exit 1
        fi
      fi

    elif [[ "''${MODE}" == "new" ]]; then
      ${getExe gum} log --level info "Generating new ED25519 host SSH key for ''${HOSTNAME}..."
      ${openssh}/bin/ssh-keygen -t ed25519 -N "" -C "root@''${HOSTNAME}" -f "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key"
      cp "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key"
      cp "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key.pub"
      chmod 600 "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key"
      chmod 644 "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub" "''${EXTRA_FILES}/persist/etc/ssh/ssh_host_ed25519_key.pub"

      NEW_AGE_KEY="''$(${getExe ssh-to-age} -i "''${EXTRA_FILES}/etc/ssh/ssh_host_ed25519_key.pub")"

      ${getExe gum} style \
        --border normal \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 214 \
        "GENERATED NEW HOST AGE PUBLIC KEY:
    ''${NEW_AGE_KEY}

  REQUIRED ACTIONS BEFORE COMPLETING DEPLOYMENT:
    1. Add key definition to .sops.yaml:
         - &''${HOSTNAME//-/_} ''${NEW_AGE_KEY}
    2. Add key reference '*''${HOSTNAME//-/_}' to rules in .sops.yaml
    3. Update secrets: sops updatekeys secrets/global.yaml
    4. Create secrets/hosts/''${HOSTNAME}.yaml if needed"

      if [[ -f .sops.yaml ]] && grep -q "''${NEW_AGE_KEY}" .sops.yaml 2>/dev/null; then
        ${getExe gum} log --level info "Key already verified in .sops.yaml."
      else
        if ! ${getExe gum} confirm "Have you updated .sops.yaml and re-encrypted secrets?"; then
          ${getExe gum} log --level error "Please update .sops.yaml and secrets, then rerun deploy-host."
          exit 1
        fi
      fi

    elif [[ "''${MODE}" == "reinstall" ]] && [[ "''${COPY_HOST_KEYS}" = true ]]; then
      ${getExe gum} log --level info "Reinstall mode: --copy-host-keys is enabled."
      ${getExe gum} log --level info "Existing host SSH keys will be copied from target ''${TARGET}."
    fi

    ${getExe gum} log --level info "4. Executing nixos-anywhere..."

    ANYWHERE_CMD=("${getExe nixos-anywhere}" "--flake" ".#''${HOSTNAME}")

    if [[ -d "''${EXTRA_FILES}" ]] && [[ -n "''$(ls -A "''${EXTRA_FILES}/etc/ssh")" ]]; then
      ANYWHERE_CMD+=("--extra-files" "''${EXTRA_FILES}")
    fi

    if [[ "''${COPY_HOST_KEYS}" = true ]]; then
      ANYWHERE_CMD+=("--copy-host-keys")
    fi

    if [[ "''${GENERATE_HWCONFIG}" = true ]]; then
      ANYWHERE_CMD+=("--generate-hardware-config" "nixos-generate-config" "./hosts/''${HOSTNAME}-hardware.nix")
    fi

    if [[ "''${DEBUG}" = true ]]; then
      ANYWHERE_CMD+=("--debug")
    fi

    if [[ "''${VM_TEST}" = true ]]; then
      ANYWHERE_CMD+=("--vm-test")
    else
      ANYWHERE_CMD+=("''${TARGET}")
    fi

    if [[ "''${DRY_RUN}" = true ]]; then
      ${getExe gum} style \
        --border double \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 212 \
        "DRY RUN SUMMARY (No changes made)

    Hostname:            ''${HOSTNAME}
    Target SSH:          ''${TARGET:-N/A (VM Test)}
    Mode:                ''${MODE}
    Copy Host Keys:      ''${COPY_HOST_KEYS}
    Generate HW Config:  ''${GENERATE_HWCONFIG}
    VM Test Mode:        ''${VM_TEST}
    Debug Mode:          ''${DEBUG}
    Extra Files Dir:     ''${EXTRA_FILES}

  Command that WOULD be executed:
    ''${ANYWHERE_CMD[*]}"

      ${getExe gum} log --level info "Dry run completed successfully."
      exit 0
    fi

    ${getExe gum} log --level info "Running: ''${ANYWHERE_CMD[*]}"

    "''${ANYWHERE_CMD[@]}"

    if [[ "''${VM_TEST}" = false ]]; then
      ${getExe gum} style \
        --border double \
        --margin "1 0" \
        --padding "1 2" \
        --border-foreground 82 \
        "Deployment completed successfully for ''${HOSTNAME}!

  Post-Installation Notes:
    1. SSH Host Key Mismatch:
       Remove stale entry from known_hosts if needed:
         ssh-keygen -R ''${TARGET#*@}

    2. System Access & Hardening:
       Root SSH login is DISABLED by modules/services/ssh.nix.
       Log in as user 'dom' using your SSH / YubiKey identity:
         ssh dom@''${TARGET#*@}

    3. Elevated Privileges:
       Use 'run0' instead of 'sudo' for admin tasks:
         run0 <command>

    4. Secrets Activation:
       Verify sops-nix decrypted secrets on first boot:
         systemctl status sops-nix.service"
    fi
''
