{ osConfig, lib, pkgs, ... }:

{
  programs.ags = lib.mkIf osConfig.programs.niri.enable {
    enable = true;
    configDir = null;
    extraPackages = [ pkgs.residence ];
  };

  systemd.user.services.residence = lib.mkIf osConfig.programs.niri.enable {
    Unit = {
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.residence;
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
