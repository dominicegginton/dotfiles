{pkgs, ...}: {
  home.packages = with pkgs; [tailscale];
}
