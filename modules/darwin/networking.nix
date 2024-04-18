{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.modules.networking = {};

  config = {
    services.tailscale.enable = true;
    environment.systemPackages = with pkgs; [tailscale];
  };
}
