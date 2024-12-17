{ config, lib, pkgs, ... }:

with lib;

let
  directory = "/root/bitwarden-secrets";
  mount = "/run/bitwarden-secrets";
  environment = "etc/bitwarden-secrets.env";
  setup = ''
    ${pkgs.busybox}/bin/mkdir -p ${directory} || true
    ${pkgs.busybox}/bin/mkdir -p ${directory}/root || true
    ${pkgs.busybox}/bin/mkdir -p ${mount} || true
    ${pkgs.util-linux}/bin/mount -t ramfs -o ramfs ${mount} || true
    ${pkgs.busybox}/bin/chmod 700 ${directory}
    ${pkgs.busybox}/bin/chmod 700 ${directory}/root
    ${pkgs.busybox}/bin/chmod 700 ${mount}
    ${pkgs.busybox}/bin/chown root:root ${directory}
    ${pkgs.busybox}/bin/chown root:root ${directory}/root
    ${pkgs.busybox}/bin/chown root:root ${mount}
  '';
  install = ''
    secrets=$(${pkgs.busybox}/bin/find ${directory}/root -type f)
    for secret in $secrets; do
      name=$(basename $secret)
      ln -sf $secret ${mount}/$name
      echo [BWS] Secret linked: ${mount}/$name
    done
  '';
  sync = ''
    source ${environment}
    export BWS_ACCESS_TOKEN
    export BWS_PROJECT_ID
    echo [BWS] Syncing secrets
    ${pkgs.bws}/bin/bws secret list "$BWS_PROJECT_ID" --output json > ${directory}/secrets.json
    echo [BWS] Secrets file sycned: ${directory}/secrets.json
    secret_ids=$(${pkgs.jq}/bin/jq -r '.[] | .id' ${directory}/secrets.json)
    for id in $secret_ids; do
      name=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      if [ -z "$name" ] || [ -z "$value" ]; then
        echo [BWS] Skipping secret with id $id, name or value is empty
        continue
      fi
      echo $value | ${pkgs.busybox}/bin/sed 's/\\n/\n/g' > ${directory}/root/$name
      chown root:root ${directory}/root/$name
      chmod 600 ${directory}/root/$name
    done
  '';
  restart-network = ''
    ${pkgs.systemd}/bin/systemctl restart wpa_supplicant.service
  '';
in

{
  config = {
    systemd.services.secrets = {
      wantedBy = [ "systemd-sysusers.service" "network.target" "network-setup.service" ];
      before = [ "systemd-sysusers.service" "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = concatStringsSep "\n" [ setup install ];
    };

    system.activationScripts.secrets-sync = {
      deps = [ "usrbinenv" ];
      text = concatStringsSep "\n" [ setup sync install restart-network ];
    };
  };
}
