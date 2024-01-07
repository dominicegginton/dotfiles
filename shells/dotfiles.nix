{
  inputs,
  pkgs,
  system,
}:
pkgs.${system}.mkShell rec {
  inherit
    (inputs.sops-nix.packages."${system}")
    sops-import-keys-hook
    ssh-to-pgp
    sops-init-gpg-key
    ;
  NIX_CONFIG = "experimental-features = nix-command flakes";
  sopsPGPKeyDirs = ["./secrets/keys"];
  nativeBuildInputs = with pkgs.${system}; [
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
