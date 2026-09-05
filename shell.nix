{
  lib,
  pkgs,
  mkShell,
  terranix,
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
  terranixConfig = terranix.lib.terranixConfiguration {
    inherit (pkgs) system;
    inherit pkgs;
    modules = [ ./infrastructure ];
  };

  terranixCli = terranix.packages.${pkgs.system}.default or pkgs.terranix or null;

  terraformWithTerranix = pkgs.writeShellScriptBin "terraform" ''
    set -euo pipefail

    dir="''${TF_ROOT_DIR:-$PWD}"
    if [ -d "$dir/infrastructure" ]; then
      infra_dir="$dir/infrastructure"
    elif [ -f "$dir/default.nix" ]; then
      infra_dir="$dir"
    else
      infra_dir="$PWD"
    fi

    # Sync evaluated Terranix JSON configuration into infrastructure working directory
    cp -f "${terranixConfig}" "$infra_dir/config.tf.json"
    chmod 644 "$infra_dir/config.tf.json"

    # Authenticate GCP Application Default Credentials if required
    if ! ${getExe google-cloud-sdk} auth application-default print-access-token > /dev/null 2>&1; then
      ${getExe google-cloud-sdk} auth application-default login
    fi

    # Inject runtime secrets via secretspec
    if [ -z "''${SECRETSPEC_LOADED:-}" ]; then
      if [ -f "$infra_dir/secretspec.toml" ]; then
        export SECRETSPEC_LOADED=1
        exec ${getExe secretspec} run --reason "Infrastructure management via Terranix" -f "$infra_dir/secretspec.toml" -- "$0" "$@"
      fi
    fi

    exec ${getExe pkgs.terraform} "$@"
  '';
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
    terraformWithTerranix
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
