{
  inputs,
  outputs,
  config,
  lib,
  platform,
  ...
}:
with lib; let
  cfg = config.modules.nixpkgs;
in {
  options.modules.nixpkgs = {
    allowUnfree = mkOption {
      type = types.bool;
      default = false;
      description = "Allow unfree packages to be built";
    };

    allowUnfreePredicate = mkOption {
      type = types.bool;
      default = false;
      description = "Allow unfree packages to be built";
    };
  };

  config = {
    nixpkgs = {
      hostPlatform = platform;

      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        inputs.neovim-nightly-overlay.overlay
      ];

      config.allowUnfree = cfg.allowUnfree or cfg.allowUnfreePredicate;
      config.allowUnfreePredicate = cfg.allowUnfree or cfg.allowUnfreePredicate;
      config.joypixels.acceptLicense = cfg.allowUnfree or cfg.allowUnfreePredicate;
    };
  };
}
