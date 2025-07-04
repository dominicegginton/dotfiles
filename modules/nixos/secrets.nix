{ config, lib, pkgs, ... }:

with lib;
with pkgs.writers;

let
  directory = "/root/bitwarden-secrets";
  mountpoint = "/run/bitwarden-secrets";
  secret-install = { name, secret }:
    let
      id = if (isString secret) then secret else secret.id;
      user = if (isString secret) then "root" else (if secret.user == "" then "root" else secret.user);
      permissions = if (isString secret) then "700" else (if secret.permissions == "" then "700" else secret.permissions);
    in
    ''
      value=$(jq -r ".[] | select(.id == \"${id}\") | .value" ${directory}/secrets.json)
      rm -f ${directory}/secrets/${name}
      echo $value | sed 's/\\n/\n/g' > ${directory}/secrets/${name}
      chown ${user}:${user} ${directory}/secrets/${name}
      chmod ${permissions} ${directory}/secrets/${name}
      ln -sf ${directory}/secrets/${name} ${mountpoint}/${name}
      chown ${user}:${user} ${mountpoint}/${name}
      chmod ${permissions} ${mountpoint}/${name}
      gum log --level info "Installed secret ${name} (${id}) [${user}:${permissions}]"
    '';
  secrets-install = ''
    export PATH=${makeBinPath [ pkgs.toybox pkgs.jq pkgs.gum ]}:$PATH
    mkdir -p ${directory} || true
    mkdir -p ${directory}/secrets || true
    mkdir -p ${mountpoint} || true
    chmod 700 ${directory}
    chmod 700 ${directory}/secrets
    chmod 700 ${mountpoint}
    chown root:root ${directory}
    chown root:root ${directory}/secrets
    chown root:root ${mountpoint}
    ${lib.concatStringsSep "\n" (mapAttrsToList (name: secret: secret-install { inherit name secret; }) config.secrets)}
  '';
  secrets-sync = writeBashBin "secrets-sync" ''
    export PATH=${makeBinPath [ pkgs.ensure-user-is-root pkgs.toybox pkgs.gum pkgs.jq pkgs.bws ]}:$PATH
    set -efu -o pipefail
    ensure-user-is-root
    write_secrets_env() {
      BWS_PROJECT_ID=$(gum input --password --prompt "Bitwarden Secrets Project ID: " --placeholder "********")
      BWS_ACCESS_TOKEN=$(gum input --password --prompt "Bitwarden Secrets Access Token: " --placeholder "********")
      echo "BWS_PROJECT_ID=$BWS_PROJECT_ID" > ${directory}/secrets.env
      echo "BWS_ACCESS_TOKEN=$BWS_ACCESS_TOKEN" >> ${directory}/secrets.env
      gum log --level info "${directory}/secrets.env created"
    }
    get_secrets() {
      if [ ! -f ${directory}/secrets.env ]; then
        write_secrets_env
      fi
      source ${directory}/secrets.env 
      gum log --level info "Fetching secrets from Bitwarden Secrets $BWS_PROJECT_ID"
      bws secret list "$BWS_PROJECT_ID" \
        --output json \
        --access-token "$BWS_ACCESS_TOKEN" \
        > ${directory}/secrets.json \
        || {
          gum log --level error "Failed to fetch secrets from Bitwarden Secrets."
          gum confirm "Write a new secrets.env file?" && {
            write_secrets_env
            get_secrets
          } || exit 1
        }
    }
    get_secrets
    if [ ! -f ${directory}/secrets.json ]; then
      gum log --level error "Failed to create ${directory}/secrets.json"
      exit 1
    fi
    ${secrets-install}
  '';
in

{
  options.secrets =
    with types;
    let
      secretType = submodule {
        options = {
          id = mkOption {
            type = str;
            default = "";
            example = "my-secret";
            description = "Bitwarden secret ID.";
          };
          user = mkOption {
            type = str;
            default = "";
            example = "root";
            description = "User that will own the secret file.";
          };
          permissions = mkOption {
            type = str;
            default = "";
            example = "700";
            description = "Permissions for the secret file.";
          };
        };
        example = {
          id = "my-secret";
          user = "root";
          permissions = "700";
        };
      };
    in
    mkOption {
      type = attrsOf (either str secretType);
      default = { };
      example = {
        foo = "foo-secret";
        bar = { id = "secret-bar"; user = "bar"; permissions = "700"; };
      };
      description = "Attribute set of secrets to be installed.";
    };
  config = {
    systemd.services.secrets = {
      wantedBy = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = secrets-install;
    };
    system.activationScripts.secrets = {
      deps = [ "specialfs" ];
      text = ''
        if [[ -e /run/current-system ]]; then
          ./${lib.getExe secrets-sync}
        fi
      '';
    };
    system.activationScripts.users.deps = [ "secrets" ];
  };
}
