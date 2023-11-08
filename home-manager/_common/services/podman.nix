{pkgs, ...}: {
  home.packages = with pkgs; [
    podman
    podman-compose
    podman-tui
  ];
}
