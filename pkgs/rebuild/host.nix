{pkgs, ...}:
pkgs.writeShellApplication {
  name = "rebuild-host";

  runtimeInputs = with pkgs; [
    nix
  ];

  text = ''
    sudo nixos-rebuild switch --flake "$HOME"/.dotfiles
  '';
}
