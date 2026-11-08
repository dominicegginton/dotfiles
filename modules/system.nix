{ self
, config
, lib
, pkgs
, ...
}:

let
  resticBackups = config.services.restic.backups;
  systemctlCheckInhibitorFlag = if resticBackups != { } then "--check-inhibitors=yes" else "";
in

{
  systemd = lib.mkIf (!config.wsl.enable) {
    timers.security-reboot = {
      description = "Weekly security reboot";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "Sun *-*-* 04:00:00";
        Persistent = true;
      };
    };

    services.security-reboot = {
      description = "Reboot after backup jobs have finished";
      after = map (name: "restic-backups-${name}.service") (builtins.attrNames resticBackups);
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl ${systemctlCheckInhibitorFlag} reboot";
        Restart = "on-failure";
        RestartSec = "60s";
      };
    };
  };

  system = {
    # NixOS state version (enforced for system compatibility)
    stateVersion = lib.mkForce config.system.nixos.release;

    # Branding
    nixos = {
      distroName = lib.mkForce "Residence";
      distroId = lib.mkForce (if config.wsl.enable then "nixos" else "residence");
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name;
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github;
      tags = lib.mkForce [
        (lib.optionalString pkgs.stdenv.hostPlatform.isLinux "residence-linux")
        (lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "residence-darwin")
        (lib.optionalString config.wsl.enable "residence-wsl")
      ];
    };
  };
}
