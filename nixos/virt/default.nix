{ config, desktop, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.distrobox
    fuse-overlayfs
    podman-compose
    podman-tui
    unstable.podman
  ]
  ++ lib.optionals (desktop != null) [
    unstable.pods
    unstable.quickemu
    xorg.xhost
  ];

  virtualisation = {
    podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      dockerCompat = true;
      dockerSocket.enable = true;
      enable = true;
      enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };
}
