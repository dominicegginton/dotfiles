{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.niri.enable {
    environment.systemPackages = [
      pkgs.waybar
      pkgs.fuzzel
    ];
  };
}
