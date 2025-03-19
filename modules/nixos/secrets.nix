{ config, lib, pkgs, ... }:

with lib;
with pkgs.writers;

let
  directory = "/root/bitwarden-secrets";
  mountpoint = "/run/bitwarden-secrets";
  secretType = types.attrsOf types.str;
  secret-install = { name, id }: ''
    value=$(jq -r ".[] | select(.id == \"${id}\") | .value" ${directory}/secrets.json | sed 's/\\n/\\\\n/g')
    if [ -f ${directory}/secrets/${name} ]; then
      if [ "$(cat ${directory}/secrets/${name})" = "$value" ]; then
        echo "Secret ${name} already exists and is the same. Skipping."
      fi
      echo "Secret ${name} already exists but is different. Overwriting."
      echo $value > ${directory}/secrets/${name}
    else
      echo "Secret ${name} does not exist. Creating."
      echo $value > ${directory}/secrets/${name}
      chown root:root ${directory}/secrets/${name}
      chmod 700 ${directory}/secrets/${name}
      ln -sf ${directory}/secrets/${name} ${mountpoint}/${name}
      chown root:root ${mountpoint}/${name}
      chmod 700 ${mountpoint}/${name}
    fi
  '';
  secrets-install = ''
    mkdir -p ${directory} || true
    mkdir -p ${directory}/secrets || true
    mkdir -p ${mountpoint} || true
    mount -t tmpfs none ${mountpoint} || true
    chmod 700 ${directory}
    chmod 700 ${directory}/secrets
    chmod 700 ${mountpoint}
    chown root:root ${directory}
    chown root:root ${directory}/secrets
    chown root:root ${mountpoint}
    ${lib.concatStringsSep "\n" (mapAttrsToList (name: id: secret-install { inherit name id; }) config.modules.secrets)}
  '';
  secrets-sync = writeBashBin "secrets-sync" ''
    export PATH=${makeBinPath [ pkgs.ensure-user-is-root pkgs.busybox pkgs.gum pkgs.jq pkgs.bws ]}:$PATH
    set -efu -o pipefail
    ensure-user-is-root
    write_secrets_env() {
      BWS_PROJECT_ID=$(gum input --password --prompt "Bitwarden Secrets Project ID: " --placeholder "********")
      BWS_ACCESS_TOKEN=$(gum input --password --prompt "Bitwarden Secrets Access Token: " --placeholder "********")
      echo "BWS_PROJECT_ID=$BWS_PROJECT_ID" > ${directory}/secrets.env
      echo "BWS_ACCESS_TOKEN=$BWS_ACCESS_TOKEN" >> ${directory}/secrets.env
      gum log --level info "env created"
    }
    if [ -f ${directory}/secrets.env ]; then
      gum confirm "${directory}/secrets.env already exists. Overwrite? (y/n)" && write_secrets_env
    else
      write_secrets_env
    fi
    source ${directory}/secrets.env
    gum spin \
      --show-output \
      --title "Syncing secrets from Bitwarden Secrets $BWS_PROJECT_ID" \
      -- bws secret list "$BWS_PROJECT_ID" \
        --output json \
        --access-token "$BWS_ACCESS_TOKEN" \
        > ${directory}/secrets.json
    if [ ! -f ${directory}/secrets.json ]; then gum log --level error "Failed to create ${directory}/secrets.json"; exit 1; fi
    ${secrets-install}
  '';
in

{
  options.modules.secrets = mkOption {
    type = secretType;
    default = { };
  };
  config = {
    systemd.services.secrets = {
      wantedBy = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        export PATH=${makeBinPath [ pkgs.busybox pkgs.jq ]}:$PATH
        ${secrets-install}
      '';
    };
    system.activationScripts.secrets = {
      text = config.systemd.services.secrets.script;
      deps = [ "specialfs" ];
    };
    system.activationScripts.users.deps = [ "secrets" ];
    environment.systemPackages = [ secrets-sync ];
  };
}
