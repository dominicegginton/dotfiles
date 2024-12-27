{ config, lib, pkgs, ... }:

let
  directory = "/root/bitwarden-secrets";
  mount = "/run/bitwarden-secrets";
in

{
  config = {
    systemd.services.secrets = {
      wantedBy = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      before = [ "systemd-sysusers.service" "systemd-tmpfiles-setup.service" "network.target" "network-setup.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      script = ''
        ${pkgs.busybox}/bin/mkdir -p ${directory} || true
        ${pkgs.busybox}/bin/mkdir -p ${directory}/secrets || true
        ${pkgs.busybox}/bin/mkdir -p ${mount} || true
        ${pkgs.busybox}/bin/mount -t tmpfs none ${mount} || true
        ${pkgs.busybox}/bin/chmod 700 ${directory}
        ${pkgs.busybox}/bin/chmod 700 ${directory}/secrets
        ${pkgs.busybox}/bin/chmod 700 ${mount}
        ${pkgs.busybox}/bin/chown root:root ${directory}
        ${pkgs.busybox}/bin/chown root:root ${directory}/secrets
        ${pkgs.busybox}/bin/chown root:root ${mount}
        secrets=$(${pkgs.busybox}/bin/find ${directory}/secrets -type f)
        for secret in $secrets; do
          name=$(basename $secret)
          ${pkgs.busybox}/bin/ln -sf ${directory}/secrets/$name ${mount}/$name
          ${pkgs.busybox}/bin/chown root:root ${mount}/$name
          ${pkgs.busybox}/bin/chmod 600 ${mount}/$name
        done
      '';
    };
  };
}
