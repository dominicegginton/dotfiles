{
  pkgs ? (import ./nixpkgs.nix),
  sops,
  sops-import-keys-hook,
  ssh-to-pgp,
  sops-init-gpg-key,
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    sopsPGPKeyDirs = ["./secrets/keys"];
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      ssh-to-pgp
      sops
      sops-import-keys-hook
      ssh-to-pgp
      sops-init-gpg-key
      workspace.rebuild-host
      workspace.rebuild-home
      workspace.rebuild-iso-console
      workspace.gpg-import-keys
    ];
  };
}
