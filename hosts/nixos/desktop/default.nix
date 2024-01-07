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
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;

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

  environment.systemPackages = with pkgs; [
    alacritty
    firefox
  ];
}
