{ lib, pkgs, ... }:
{
  programs.ags = {
    enable = true;
    configDir = null;
    extraPackages = [ pkgs.residence ];
  };

  systemd.user.services.residence = {
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
