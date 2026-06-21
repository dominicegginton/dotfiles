{
  # shell.nix
  #
  # Development shell for the dotfiles project, providing tools for Nix development, secrets management, and project automation.
  #
  # This shell is intended for use with `nix develop` and provides all tools needed for working on this repository.
  lib,
  mkShell,
  writeShellScriptBin,
  nix,
  nix-output-monitor,
  deadnix,
  statix,
  nix-diff,
  nix-tree,
  nix-health,
  nix-index,
  google-cloud-sdk,
  opentofu,
  sops,
  age,
  ssh-to-age,
  mkpasswd,
}:

mkShell rec {
  name = "github:" + lib.maintainers.dominicegginton.github + "/dotfiles";
  keys = [ "root@dominicegginton.dev" ];

  # Development tools and project scripts
  packages = [
    nix
    nix-output-monitor
    deadnix
    statix
    nix-diff
    nix-tree
    nix-health
    nix-index
    google-cloud-sdk
    opentofu
    sops
    age
    ssh-to-age
    mkpasswd
    # Helper to edit secrets
    (writeShellScriptBin "edit-secrets" ''
      sops secrets/secrets.yaml
    '')
  ];

  # Maintainer info for shell.nix
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
