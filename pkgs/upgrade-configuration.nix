{pkgs, ...}:
pkgs.writeShellApplication {
  name = "upgrade-configuration";

  runtimeInputs = with pkgs; [
    nix
    home-manager
    rebuild-configuration
  ];

  text = ''
    pushd "$HOME"/.dotfiles
    nix flake update
    rebuild-configuration
  '';
}
