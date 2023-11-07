{pkgs, ...}:
pkgs.writeShellApplication {
  name = "rebuild-darwin";

  runtimeInputs = with pkgs; [
    nix
  ];

  text = ''
    nix run nix-darwin -- switch --flake "$HOME"/.dotfiles
  '';
}
