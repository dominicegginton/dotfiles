{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.tailscale;
  inherit (pkgs.stdenv) isLinux;
in {
  options.modules.tailscale = {
    enable = mkEnableOption "tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall = mkIf isLinux {
      checkReversePath = "loose";
      allowedUDPPorts = [config.services.tailscale.port];
      trustedInterfaces = ["tailscale0"];
    };

    environment.systemPackages = with pkgs; [tailscale];
  };
}
