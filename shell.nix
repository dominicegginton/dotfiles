{
  inputs,
  pkgs,
  system,
}: let
  inherit
    (inputs.sops-nix.packages."${system}")
    sops-import-keys-hook
    ssh-to-pgp
    sops-init-gpg-key
    ;
in
  pkgs.mkShell rec {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      ssh-to-pgp
      sops
      sops-import-keys-hook
      sops-init-gpg-key
      pinentry
    ];
  }
