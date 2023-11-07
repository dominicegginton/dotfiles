{
  inputs,
  outputs,
  hostname,
  platform,
  darwinStateVersion,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./${hostname}/default.nix
    ./_common/services/homebrew.nix
  ];

  nixpkgs = {
    hostPlatform = platform;
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.neovim-nightly-overlay.overlay
      inputs.nixneovimplugins.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
    package = pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    pinentry
    rebuild-darwin
    network-filters-disable
    network-filters-enable
  ];

  services.nix-daemon.enable = true;

  system.stateVersion = darwinStateVersion;
}