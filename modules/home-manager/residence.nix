{ osConfig, lib, pkgs, ... }:

{
  programs.ags = lib.mkIf osConfig.display.residence.enable {
    enable = true;
    configDir = null;
    extraPackages = [ pkgs.residence ];
  };

  systemd.user.services.residence = lib.mkIf osConfig.display.residence.enable {
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
}
