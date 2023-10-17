{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "rebuild-iso-console";

  runtimeInputs = with pkgs; [
    nix
  ];

  text = ''
    pushd "$HOME"/.dotfiles
    nix build .#nixosConfigurations.iso.config.system.build.isoImage
    popd
  '';
}
