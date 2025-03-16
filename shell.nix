{ pkgs, mkShell }:

mkShell {
  nativeBuildInputs = with pkgs; [
    (lib.development-prompt "dominicegginton/dotfiles")
    nix
    deadnix
    nixpkgs-fmt
    nix-weather
    bootstrap-nixos-host
    bootstrap-nixos-installer
    git-cleanup
    git-sync
  ];
  NIX_SSHOPTS = "-t";
}
