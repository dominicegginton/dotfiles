{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  imports = [
    ./sway.nix
    ./gamescope.nix
  ];

  options.modules.desktop.packages = mkOption {
    type = types.listOf types.package;
    default = [];
  };

  config = rec {
    boot.plymouth.enable = true;
    boot.plymouth.theme = "spinner";
    fonts.enableDefaultPackages = false;
    fonts.fontDir.enable = true;
    environment.systemPackages = cfg.packages;
  };
}
