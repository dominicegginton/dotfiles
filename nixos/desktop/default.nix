{
  desktop,
  lib,
  pkgs,
  ...
}: {
  imports =
    [
      ../hardware/opengl.nix
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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.dconf.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };
}
