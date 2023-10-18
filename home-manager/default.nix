{ config
, desktop
, hostname
, inputs
, lib
, outputs
, pkgs
, stateVersion
, username
, ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
in

{
  imports = [
    ./_common/console
  ]
  ++ lib.optional (builtins.isPath (./. + "/_common/users/${username}")) ./_common/users/${username}
  ++ lib.optional (builtins.pathExists (./. + "/_common/users/${username}/hosts/${hostname}.nix")) ./_common/users/${username}/hosts/${hostname}.nix
  ++ lib.optional (desktop != null) ./_common/desktop;

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
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
      inputs.firefox-darwin-overlay.overlay
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;
}
