{
  config,
  pkgs,
  ...
}: {
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [config.services.tailscale.port];
    trustedInterfaces = ["tailscale0"];
  };

  environment.systemPackages = with pkgs; [tailscale];
}
