# infrastructure/shell.nix
#
# Development shell for infrastructure work, providing tools for cloud, GitHub, and Terraform workflows.

{
  lib,
  pkgs,
  mkShell,
  google-cloud-sdk,
  secretspec,
  gh,
}:

let
  tfHelpers = lib.terraform pkgs;
  terraformWithPlugins = tfHelpers.mkTerraformDerivation {
    name = "personal-infra";
    package = pkgs.terraform;
    providers = tfHelpers.defaultProviders;
    paths = [ ./. ];
    validate = false;
    preCommand = ''
      if ! ${lib.getExe google-cloud-sdk} auth application-default print-access-token > /dev/null 2>&1; then
        ${lib.getExe google-cloud-sdk} auth application-default login
      fi
      if [ -z "''${SECRETSPEC_LOADED:-}" ] && [ -f "$dir/secretspec.toml" ]; then
        export SECRETSPEC_LOADED=1
        exec ${lib.getExe secretspec} run --reason "Infrastructure management via Terraform" -f "$dir/secretspec.toml" -- "$0" "$@"
      fi
    '';
  };
in

mkShell {
  name = "dominicegginton/dotfiles/infrastructure";

  packages = [
    google-cloud-sdk
    secretspec
    gh
    terraformWithPlugins
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
