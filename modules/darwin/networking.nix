{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = rec {
    services.tailscale.enable = true;
    environment.systemPackages = with pkgs; [tailscale];
  };
}
