{ pkgs, ... }:

{
  imports = [
    ./namespace.nix
    ./distributed.nix
  ];

  boot = {
    kernelModules = [ "9p" "9pnet_virtio" "9pnet_tcp" ];
    initrd.kernelModules = [ "9p" "9pnet_virtio" "9pnet_tcp" ];
    supportedFilesystems = [ "9p" "overlay" ];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    tmux
    neovim
    plan9port
  ];
}
