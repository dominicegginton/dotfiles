{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.gamescope;
in {
  options.modules.gamescope = {
    enable = mkEnableOption "gamescope";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [gamescope];
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
    };
  };
}
