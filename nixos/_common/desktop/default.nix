{ desktop, lib, pkgs, ... }:

{
  imports = [
    ../services/cups.nix
  ]
  ++ lib.optional (builtins.pathExists (./. + "/${desktop}/desktop.nix")) ./${desktop}/desktop.nix ++ lib.optional (builtins.pathExists (./. + "/${desktop}/apps.nix")) ./${desktop}/apps.nix;

  boot = {
    plymouth = {
      enable = true;
      theme = "spinner";
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  programs.dconf.enable = true;

  systemd.services.disable-wifi-powersave = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iw ];
    script = ''
      iw dev wlan0 set power_save off
    '';
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
}
