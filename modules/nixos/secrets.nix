{ inputs, config, lib, pkgs, ... }:

with lib;

let
  inherit (inputs) BWS_ACCESS_TOKEN BWS_PROJECT_ID;

  accessToken = pkgs.stdenv.mkDerivation {
    name = "bitwarden-access-token";
    dontUnpack = true;
    buildPhase = ''
      echo ${builtins.readFile BWS_ACCESS_TOKEN.outPath} > ACCESS_TOKEN
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
      echo ${builtins.readFile BWS_PROJECT_ID.outPath} > PROJECT_ID
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
    systemd.services.secrets = {
      wants = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = ''
        unmount /root/secrets/bitwarden || true
        rm -rf /root/secrets/bitwarden || true
        mkdir -p /root/secrets/bitwarden
        mount -t tmpfs -o size=1M tmpfs /root/secrets/bitwarden
        chown root:root /root/secrets/bitwarden
        export BWS_ACCESS_TOKEN=$(cat ${accessToken}/ACCESS_TOKEN)
        export BWS_PROJECT_ID=$(cat ${projectId}/PROJECT_ID)
        echo "Getting Bitwarden secrets"
        ${config.modules.bitwarden.package}/bin/bws secret list "$BWS_PROJECT_ID" --output json > /root/secrets/bitwarden/secrets.json
        echo "Linking secrets to /run/bitwarden-secrets"
        ln -s /root/secrets/bitwarden/secrets.json /run/bitwarden-secrets
        echo "Unmounting secrets"
        unmount /root/secrets/bitwarden || true
        rm -rf /root/secrets/bitwarden || true
      '';
    };

    system.activationScripts.secrets = {
      deps = [ "usrbinenv" ];
      text = config.systemd.services.secrets.script;
    };
  };
}
