{ pkgs, ... }:
{
  programs.ags = {
    enable = true;
    configDir = null;
    extraPackages = [
      pkgs.my-shell
    ];
  };

  systemd.user.services.my-shell = {
    Unit = {
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.my-shell}/bin/my-shell";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
