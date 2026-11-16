{ config, pkgs, lib, ... }:

{
  imports = [
    ./namespace.nix
    ./distributed.nix
  ];

  system.stateVersion = "26.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    tmux
    neovim
    plan9port
  ];
}
