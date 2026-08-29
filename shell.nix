{
  lib,
  pkgs,
  mkShell,
  nix,
  nix-output-monitor,
  deadnix,
  statix,
  nix-diff,
  nix-tree,
  nix-health,
  nix-index,
  google-cloud-sdk,
  secretspec,
  sops,
  age,
  ssh-to-age,
  mkpasswd,
  nixos-anywhere,
  gnupg,
  openssh,
  deploy-host,
  burn-infector,
  gpg-import-bucket,
  gcs-restore,
  ...
}:

with builtins;
with lib;

let
  tfHelpers = lib.terraform pkgs;

  terraformWithPlugins = tfHelpers.mkTerraformDerivation {
    name = "personal-infra";
    package = pkgs.terraform;
    providers = tfHelpers.defaultProviders;
    paths = [ ./infrastructure ];
    validate = false;
    preCommand = ''
      if ! ${getExe google-cloud-sdk} auth application-default print-access-token > /dev/null 2>&1; then
        ${getExe google-cloud-sdk} auth application-default login
      fi
      if [ -z "''${SECRETSPEC_LOADED:-}" ] && [ -f "$dir/secretspec.toml" ]; then
        export SECRETSPEC_LOADED=1
        exec ${getExe secretspec} run --reason "Infrastructure management via Terraform" -f "$dir/secretspec.toml" -- "$0" "$@"
      fi
    '';
  };
in

mkShell rec {
  name = "github:" + maintainers.dominicegginton.github + "/dotfiles";
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
    terraformWithPlugins
    secretspec
    sops
    age
    ssh-to-age
    mkpasswd
    nixos-anywhere
    gnupg
    openssh
    deploy-host
    burn-infector
    gpg-import-bucket
    gcs-restore
  ];

  # Maintainer info for shell.nix
  meta.maintainers = [ maintainers.dominicegginton ];
}
