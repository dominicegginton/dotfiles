{ lib, pkgs, ... }:

{
  config.console = {
    enable = lib.mkForce true;
    earlySetup = lib.mkForce true;
    keyMap = lib.mkDefault "uk";
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
  };
}
