{
  inputs,
  NIX_CONFIG,
  pkgs,
  developmentPkgs ? [],
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
    inherit NIX_CONFIG;
    nativeBuildInputs = with pkgs;
      [
        nix
        home-manager
        ssh-to-pgp
        sops
        sops-import-keys-hook
        sops-init-gpg-key
        pinentry
      ]
      ++ developmentPkgs;
  }
