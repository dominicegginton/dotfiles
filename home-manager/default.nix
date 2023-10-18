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
    ./_common/modules/alias-applications.nix
  ]
  ++ lib.optional (builtins.isPath (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
  ++ lib.optional (builtins.pathExists (./. + "/_mixins/users/${username}/hosts/${hostname}.nix")) ./_mixins/users/${username}/hosts/${hostname}.nix
  ++ lib.optional (desktop != null) ./_mixins/desktop;

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
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    package = pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };
}
