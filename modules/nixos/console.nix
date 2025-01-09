{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    console.enable = true;
    console.earlySetup = true;
    console.keyMap = "uk";
    console.font = mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u22n.psf.gz";
    console.colors = config.scheme.toList;
  };
}
