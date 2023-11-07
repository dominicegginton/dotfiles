{
  desktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ../services/cups.nix
      ../services/pipewire.nix
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}/desktop.nix")) ./${desktop}/desktop.nix
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}/apps.nix")) ./${desktop}/apps.nix;

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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
}
