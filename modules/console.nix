{ config, pkgs, ... }:

{
  config.console = {
    enable = true;
    earlySetup = true;
    keyMap = "uk";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
  };
}
