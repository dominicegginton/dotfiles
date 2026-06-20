{
  self,
  config,
  lib,
  pkgs,
  hostname,
  tailnet,
  ...
}:

{
  # Tailscale service configuration
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = lib.mkForce (if notWSL then "both" else "client");
    extraUpFlags = [
      "--ssh"
      "--accept-dns"
    ]
    ++ lib.optionals notWSL [ "--accept-routes" ];
    extraSetFlags = [ "--posture-checking=true" ];
    interfaceName = lib.mkForce tailscaleInterface;
  };

  # ACME configuration for SSL certificates
  security.acme = {
    acceptTerms = lib.mkDefault true;
    defaults.email = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.email;
  };
}
