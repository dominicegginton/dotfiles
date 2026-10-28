{ self
, config
, lib
, pkgs
, ...
}:

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
      after = map (name: "restic-backups-${name}.service") (
        builtins.attrNames config.services.restic.backups
      );
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --check-inhibitors=yes reboot";
        Restart = "on-failure";
        RestartSec = "60s";
      };
    };
  };

  system = {
    # NixOS state version (enforced for system compatibility)
    stateVersion = lib.mkForce config.system.nixos.release;

    # Enforce branding for all systems
    nixos = {
      distroName = lib.mkForce "Residence"; # Branding: always "Residence"
      # VS Code's WSL server checks ID rather than ID_LIKE to recognize NixOS.
      distroId = lib.mkForce (if config.wsl.enable then "nixos" else "residence");
      vendorName = lib.mkForce self.outputs.lib.maintainers.dominicegginton.name; # Branding
      vendorId = lib.mkForce self.outputs.lib.maintainers.dominicegginton.github; # Branding
      tags = lib.mkForce [
        (lib.optionalString pkgs.stdenv.hostPlatform.isLinux "residence-linux")
        (lib.optionalString config.wsl.enable "wsl")
      ];
    };
  };
}
