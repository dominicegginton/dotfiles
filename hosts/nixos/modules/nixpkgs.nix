# Nix packages
#
# Configuration for Nix packages.
{
  inputs,
  outputs,
  platform,
  ...
}: {
  nixpkgs = {
    hostPlatform = platform;

    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.neovim-nightly-overlay.overlay
    ];

    # Allow unfree packages.
    config.allowUnfree = true;
    config.allowUnfreePredicate = _: true;

    # Accept the JoyPixels license.
    config.joypixels.acceptLicense = true;
  };
}
