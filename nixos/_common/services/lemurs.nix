{ config, lib, pkgs, ... }:

let
  cfg = config.services.lemurs;
in

{
  options.services.lemurs = {
    enable = lib.mkEnableOption "Enable lemurs service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.lemurs;
      defaultText = "pkgs.unstable.lemurs";
      description = "Set version of lemurs package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbus.packages = [ cfg.package ];

    systemd.services.lemurs = {
      description = "lemurs server daemon.";

      after = [ "systemd-udev-settle.service" "local-fs.target" "acpid.service" "systemd-logind.service" ];

      restartIfChanged = false;

      serviceConfig = {
        ExecStart = "/usr/bin/lemurs";
        Restart = "always";
        RestartSec = "200ms";
        SyslogIdentifier = "display-manager";
      };
    };
  };
}
