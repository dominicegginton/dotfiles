{ config, lib, pkgs, ... }:

with lib;

let
  directory = "/root/bitwarden-secrets";
  mount = "/run/bitwarden-secrets";
  environment = "etc/bitwarden-secrets.env";
  setup = ''
    ${pkgs.busybox}/bin/install -d -m700 ${directory}
    ${pkgs.busybox}/bin/install -d -m700 ${directory}/root
    ${pkgs.busybox}/bin/install -d -m700 ${mount}
    ${pkgs.util-linux}/bin/umount ${mount} || true
    ${pkgs.util-linux}/bin/mount -t ramfs -o size=1M ramfs ${mount}
  '';
  sync = ''
    source ${environment}
    export BWS_ACCESS_TOKEN
    export BWS_PROJECT_ID
    ${pkgs.bws}/bin/bws secret list "$BWS_PROJECT_ID" --output json > ${directory}/secrets.json
  '';
  install = ''
    secret_ids=$(${pkgs.jq}/bin/jq -r '.[] | .id' ${directory}/secrets.json)
    for id in $secret_ids; do
      name=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      echo $value | ${pkgs.busybox}/bin/sed 's/\\n/\n/g' > ${directory}/root/$name
      chown root:root ${directory}/root/$name
      chmod 600 ${directory}/root/$name
      ln -sf ${directory}/root/$name ${mount}/$name
    done
  '';
in


{
  config = {
    systemd.services.secrets = {
      wantedBy = [ "sysinit.target" "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = concatStringsSep "\n" [ setup install ];
    };

    systemd.services.secrets-sync = {
      wants = [ "secrets.service" "network-online.target" ];
      after = [ "secrets.service" "network.target" "network-online.target" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        Type = "oneshot";
        StandardOutput = "null";
        StandardError = "null";
        RemainAfterExit = true;
      };
      script = concatStringsSep "\n" [ sync install ];
    };

    system.activationScripts.secrets-sync = {
      deps = [ "usrbinenv" ];
      text = config.systemd.services.secrets-sync.script;
    };
  };
}
