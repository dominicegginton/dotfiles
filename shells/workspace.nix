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

    # Set the default PGP key directory to
    # be used by sops. This is the directory
    # where the public PGP keys are stored.
    sopsPGPKeyDirs = [".keys"];

    nativeBuildInputs = with pkgs;
      [
        nix # Nix package manager
        home-manager # Home manager
        ssh-to-pgp # Script to import SSH keys to GPG
        sops # Sops secret management tool
        sops-import-keys-hook # Sops hook to import PGP keys
        sops-init-gpg-key # Sops hook to initialize GPG key
      ]
      ++ developmentPkgs;
  }
