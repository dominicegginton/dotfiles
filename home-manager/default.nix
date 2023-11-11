{
  inputs,
  outputs,
  lib,
  config,
  hostname,
  username,
  desktop,
  pkgs,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (lib) optional;
  inherit (builtins) pathExists;
in {
  imports =
    [
      inputs.nixvim.homeManagerModules.nixvim
      ./_common/console
      ./_common/services/gpg.nix
    ]
    ++ optional (pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
    ++ optional (pathExists (./. + "/users/${username}")) ./users/${username}
    ++ optional (pathExists (./. + "/users/${username}/console")) ./users/${username}/console
    ++ optional (desktop != null && pathExists (./. + /users/${username}/desktop)) ./users/${username}/desktop
    ++ optional (pathExists (./. + "/users/${username}/sources")) ./users/${username}/sources
    ++ optional (desktop != null) ./_common/desktop;

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory =
      if isDarwin
      then "/Users/${username}"
      else "/home/${username}";
    sessionPath = ["$HOME/.local/bin"];
    inherit stateVersion;
    inherit username;
  };

  nixpkgs = {
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
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [rebuild-home];
}
