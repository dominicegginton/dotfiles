{ osConfig, lib, pkgs, ... }:

{
  config = lib.mkIf osConfig.display.niri.enable {
    programs.ags = {
      enable = true;
      configDir = null;
      extraPackages = [ pkgs.residence ];
    };

    systemd.user.services.residence = {
      Unit = {
        ConditionEnvironment = [ "NIRI_SOCKET" ];
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = lib.getExe pkgs.residence;
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
