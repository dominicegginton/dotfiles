{
  inputs,
  pkgs,
  baseDevPkgs,
  platform,
}: let
  inherit
    (inputs.sops-nix.packages."${platform}")
    sops-import-keys-hook
    ssh-to-pgp
    sops-init-gpg-key
    ;
in
  pkgs.mkShell rec {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    sopsPGPKeyDirs = ["./"];
    nativeBuildInputs = with pkgs;
      baseDevPkgs
      ++ [
        nix
        home-manager
        ssh-to-pgp
        sops
        sops-import-keys-hook
        ssh-to-pgp
        sops-init-gpg-key
        workspace.rebuild-host
        workspace.rebuild-home
        workspace.rebuild-configuration
        workspace.upgrade-configuration
        workspace.workspace-formatter
        workspace.workspace-linter
        workspace.rebuild-iso-console
        workspace.gpg-import-keys
      ];
  }
