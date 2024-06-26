{ config
, lib
, ...
}:

let
  cfg = config.modules.desktop;
in

with lib;

{
  imports = [
    ./gamescope.nix
    ./plasma.nix
    ./sway.nix
  ];

  options.modules.desktop.packages = mkOption {
    type = types.listOf types.package;
    default = [ ];
  };

  config = {
    boot.plymouth.enable = true;
    boot.plymouth.theme = "spinner";
    fonts.enableDefaultPackages = false;
    fonts.fontDir.enable = true;
    environment.systemPackages = cfg.packages;
  };
}
