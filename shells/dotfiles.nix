{
  inputs,
  pkgs,
  platform,
}: let
  inherit
    (inputs.sops-nix.packages."${platform}")
    sops-import-keys-hook
    ssh-to-pgp
    sops-init-gpg-key
    ;
  packages = pkgs.${platform};
in
  pkgs.${platform}.mkShell rec {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    sopsPGPKeyDirs = ["./secrets/keys"];
    nativeBuildInputs = with packages; [
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
      workspace.format-configuration
      workspace.rebuild-iso-console
      workspace.gpg-import-keys
    ];
  }
