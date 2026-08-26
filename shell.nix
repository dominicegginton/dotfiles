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
  ...
}:

with builtins;
with lib;

let
  runTofuWithSecrets =
    tofuOperation:
    "${getExe secretspec} run --reason \"Infrastructure management via OpenTofu\" -f ./infrastructure/secretspec.toml ${getExe opentofu} -chdir=infrastructure ${tofuOperation}";

  infrastructure = {
    init = writeShellScriptBin "infrastructure-init" ''
      if ! ${getExe google-cloud-sdk} auth application-default print-access-token > /dev/null 2>&1; then
        ${getExe google-cloud-sdk} auth application-default login
      fi
      ${runTofuWithSecrets "init"}
    '';
    plan = writeShellScriptBin "infrastructure-plan" ''
      ${getExe infrastructure.init}
      ${runTofuWithSecrets "plan"}
    '';
    apply = writeShellScriptBin "infrastructure-apply" ''
      ${getExe infrastructure.plan}
      ${runTofuWithSecrets "apply"}
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
    opentofu
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
    infrastructure.init
    infrastructure.plan
    infrastructure.apply
  ];

  # Maintainer info for shell.nix
  meta.maintainers = [ maintainers.dominicegginton ];
}
