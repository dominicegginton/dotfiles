{ pkgs ? (import ./nixpkgs.nix)
, sops
, sops-import-keys-hook
, ssh-to-pgp
, sops-init-gpg-key
, ...
}:

{
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    sopsPGPKeyDirs = [ "./secrets/keys" ];
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git
      ssh-to-pgp
      sops
      sops-import-keys-hook
      ssh-to-pgp
      sops-init-gpg-key
      rebuild-host
      rebuild-home
    ];
  };
}
