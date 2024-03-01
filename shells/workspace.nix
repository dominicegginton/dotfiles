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
    sopsPGPKeyDirs = [".keys"];
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
        rebuild-host
        rebuild-home
        rebuild-configuration
        upgrade-configuration
        rebuild-iso-console
        gpg-import-keys
      ];
  }
