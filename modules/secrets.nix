{ config, lib, pkgs, ... }:

with lib;
with types;

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

  secretType = submodule rec {
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

{
  options.secrets = mkOption {
    type = attrsOf (either str secretType);
    default = { };
    example = {
      foo = "foo-secret";
      bar = { id = "secret-bar"; user = "bar"; permissions = "700"; };
    };
    description = "Attribute set of secrets to be installed.";
  };

  config = {
    systemd.services.decrypt-secrets = {
      wantedBy = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        export PATH=${makeBinPath [ pkgs.toybox pkgs.gum pkgs.jq pkgs.gnupg ]}:$PATH
        TEMP_DIR=$(mktemp -d)
        trap 'rm -rf $TEMP_DIR' EXIT
        export GPG_TTY=$(tty)
        export GPG_AGENT_INFO=/dev/null
        export GPG_KEYBOX=/dev/null
        gpg \
          --yes \
          --output $TEMP_DIR/secrets.json \
          --decrypt ${../secrets.json}
        echo "Decrypted secrets to $TEMP_DIR/secrets.json"
        if [ ! -f $TEMP_DIR/secrets.json ]; then
          gum log --level error "Failed to decrypt secrets file."
          exit 1
        fi
        mkdir -p /root/bitwarden-secrets
        mv $TEMP_DIR/secrets.json /root/bitwarden-secrets/secrets.json
        gum log --level info "Moved decrypted secrets to /root/bitwarden-secrets/secrets.json"
        chown root:root /root/bitwarden-secrets/secrets.json
        chmod 600 /root/bitwarden-secrets/secrets.json
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
    };
  };
}
