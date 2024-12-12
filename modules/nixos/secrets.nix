{ inputs, config, lib, pkgs, ... }:

with lib;

let
  inherit (inputs) BWS_ACCESS_TOKEN BWS_PROJECT_ID;

  secrets-mount-point = "/run/bitwarden-secrets";
  temp-directory = "/root/bitwarden-secrets";

  accessToken = pkgs.stdenv.mkDerivation {
    name = "bitwarden-access-token";
    dontUnpack = true;
    buildPhase = ''
      echo 0000 > ACCESS_TOKEN
    '';
    installPhase = ''
      mkdir -p $out
      cp ACCESS_TOKEN $out
    '';
  };

  projectId = pkgs.stdenv.mkDerivation {
    name = "bitwarden-project-id";
    dontUnpack = true;
    buildPhase = ''
      echo 0000 > PROJECT_ID
    '';
    installPhase = ''
      mkdir -p $out
      cp PROJECT_ID $out
    '';
  };


in

{
  options.modules.bitwarden = {
    package = mkOption {
      type = types.package;
      description = "Bitwarden secrets CLI package";
      default = pkgs.bws;
    };
  };

  config = {
    systemd.services.create-secrets-directory = {
      wantedBy = [ "sysinit.target" ];
      after = [ "systemd-sysusers.service" ];
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = ''
        echo "[BWS] Creating secrets directory"
        mkdir -p ${secrets-mount-point}
        chown root:root ${secrets-mount-point}
        chmod 700 ${secrets-mount-point}
        grep -q "${secrets-mount-point}" /proc/mounts || ${pkgs.util-linux}/bin/mount -t ramfs -o size=1M ramfs ${temp-directory} || true
        echo "[BWS] Secrets directory created"
      '';
    };
    systemd.services.mount-secrets = {
      wantedBy = [ "sysinit.target" ];
      after = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "create-secrets-directory.service" ];
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = ''
        echo "[BWS] Setting up secrets"
        secrets_file_exists=$( [ -f ${temp-directory}/secrets.json ] && echo true || echo false )
        if [ "$secrets_file_exists" = "true" ]; then
          echo "[BWS] Secrets found"
          secret_ids=$(${pkgs.jq}/bin/jq -r '.[] | .id' ${temp-directory}/secrets.json)
          for id in $secret_ids; do
            name=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${temp-directory}/secrets.json)
            value=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${temp-directory}/secrets.json)
            echo $value | ${pkgs.busybox}/bin/sed 's/\\n/\n/g' > ${temp-directory}/$name
            ln -fs ${temp-directory}/$name ${secrets-mount-point}/$name
            chown root:root ${temp-directory}/$name
            chmod 600 ${temp-directory}/$name
          done
        fi

        echo "[BWS] Secrets setup complete"
      '';
    };
    systemd.services.secrets-update = {
      wantedBy = [ "sysinit.target" ];
      wants = [ "network-online.target" ];
      after = [ "systemd-sysusers.service" "network.target" "network-online.target" "mount-secrets.service" ];
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = ''
        echo "[BWS] Updating secrets"
        export BWS_ACCESS_TOKEN=$(cat ${accessToken}/ACCESS_TOKEN)
        export BWS_PROJECT_ID=$(cat ${projectId}/PROJECT_ID)
        rm -rf ${temp-directory}/*
        ${config.modules.bitwarden.package}/bin/bws secret list "$BWS_PROJECT_ID" --output json > ${temp-directory}/secrets.json
        ${config.systemd.services.mount-secrets.script}
        echo "[BWS] Secrets updated"
      '';
    };

    system.activationScripts.secrets = {
      deps = [ "usrbinenv" ];
      text = config.systemd.services.secrets-update.script;
    };
  };
}
