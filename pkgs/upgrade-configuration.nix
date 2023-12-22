{pkgs, ...}:
pkgs.writeShellApplication {
  name = "upgrade-configuration";

  runtimeInputs = with pkgs; [
    nix
    home-manager
    workspace.rebuild-configuration
  ];

  text = ''
    pushd "$HOME"/.dotfiles
    nix flake update
    rebuild-configuration
  '';
}
