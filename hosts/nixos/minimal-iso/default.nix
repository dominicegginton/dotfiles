# nix run nixpkgs\#nixos-generators -- --flake .#minimal-iso --format iso -o result
# dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync

{ pkgs, modulesPath, ... }:

{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  environment.systemPackages = with pkgs; [
    neovim
    disko
    parted
    git
  ];

  nix.settings.experimental-features = "nix-command flakes";
}
