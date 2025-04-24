{ config, pkgs, ... }:

{
  config = {
    console.enable = true;
    console.earlySetup = true;
    console.keyMap = "uk";
    console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
    console.colors = config.scheme.toList;
  };
}
