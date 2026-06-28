{
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
  ...
}:

let
  edit-secrets = writeShellScriptBin "edit-secrets" ''
    sops secrets/secrets.yaml
  '';
in

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
    edit-secrets
  ];

  # Maintainer info for shell.nix
  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
