{ config, lib, pkgs, ... }:

with lib;

let
  directory = "/root/bitwarden-secrets";
  mount = "/run/bitwarden-secrets";
  environment = "etc/bitwarden-secrets.env";
in


{
  config = {
    systemd.services.secrets = {
      wantedBy = [ "sysinit.target" "systemd-sysusers.service" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
        EnvironmentFile = environment;
      };
      script = ''
        source ${environment}
        export BWS_ACCESS_TOKEN
        export BWS_PROJECT_ID
        ${pkgs.busybox}/bin/install -d -m700 ${mount}
        ${pkgs.util-linux}/bin/umount ${mount} || true
        ${pkgs.util-linux}/bin/mount -t ramfs -o size=1M ramfs ${mount}
        ${pkgs.busybox}/bin/ping -c 1 api.bitwarden.com > /dev/null 2>&1 && ${pkgs.bws}/bin/bws secret list "$BWS_PROJECT_ID" --output json > ${directory}/secrets.json
        secret_ids=$(${pkgs.jq}/bin/jq -r '.[] | .id' ${directory}/secrets.json)
        for id in $secret_ids; do
          name=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
          value=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
          echo $value | ${pkgs.busybox}/bin/sed 's/\\n/\n/g' > ${mount}/$name
          chown root:root ${mount}/$name
          chmod 600 ${mount}/$name
        done
      '';
    };

    system.activationScripts.secrets = {
      deps = [ "usrbinenv" ];
      text = config.systemd.services.secrets.script;
    };
  };
}
