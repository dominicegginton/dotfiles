{ config, lib, pkgs, ... }:

with lib;

let
  directory = "/root/bitwarden-secrets";
  mount = "/run/bitwarden-secrets";
  environment = "etc/bitwarden-secrets.env";
  setup = ''
    ${pkgs.gum}/bin/gum log --level info "Setting up Bitwarden Secrets"
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
    ${pkgs.gum}/bin/gum log --level info "Bitwarden Secrets setup complete"
  '';
  install = ''
    ${pkgs.gum}/bin/gum log --level info "Installing Bitwarden Secrets"
    secrets=$(${pkgs.busybox}/bin/find ${directory}/root -type f)
    for secret in $secrets; do
      name=$(basename $secret)
      ln -sf $secret ${mount}/$name
      ${pkgs.gum}/bin/gum log --level info "Installed secret: ${directory}/root/$name -> ${mount}/$name"
    done
    ${pkgs.gum}/bin/gum log --level info "Bitwarden Secrets installed"
  '';
  sync = ''
    set -e -o pipefail
    source ${environment}
    export BWS_ACCESS_TOKEN
    export BWS_PROJECT_ID
    if [ -z "$BWS_ACCESS_TOKEN" ] || [ -z "$BWS_PROJECT_ID" ]; then
      ${pkgs.gum}/bin/gum log --level error "BWS_ACCESS_TOKEN and BWS_PROJECT_ID must be set in ${environment}"
      exit 1
    fi
    ${pkgs.gum}/bin/gum log --level info "Syncing Bitwarden Secrets"
    ${pkgs.bws}/bin/bws secret list "$BWS_PROJECT_ID" --output json > ${directory}/secrets.json
    secret_ids=$(${pkgs.jq}/bin/jq -r '.[] | .id' ${directory}/secrets.json)
    ${pkgs.gum}/bin/gum log --level info "Syncing $(echo $secret_ids | wc -w) secrets found in project $BWS_PROJECT_ID"
    for id in $secret_ids; do
      name=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(${pkgs.jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      if [ -z "$name" ] || [ -z "$value" ]; then
        continue
      fi
      echo $value | ${pkgs.busybox}/bin/sed 's/\\n/\n/g' > ${directory}/root/$name
      ${pkgs.gum}/bin/gum log --level info "Synced secret: $name -> ${directory}/root/$name"
      chown root:root ${directory}/root/$name
      chmod 600 ${directory}/root/$name
    done
    ${pkgs.gum}/bin/gum log --level info "Bitwarden Secrets synced"
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

    systemd.timers.secrets-sync = {
      wantedBy = [ "timers.target" ];
      wants = [ "network-online.target" ];
      after = [ "network.target" "netork-online.target" ];
      timerConfig = {
        OnCalendar = "*:0/1";
        Persistent = true;
        Unit = "secrets-sync.service";
      };
    };

    systemd.services.secrets-sync = {
      wantedBy = [ "timers.target" ];
      wants = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = concatStringsSep "\n" [ sync install ];
    };

    system.activationScripts.sync-secrets = {
      deps = [ "usrbinenv" ];
      supportsDryActivation = false;
      text = config.systemd.services.secrets-sync.script;
    };
  };
}
