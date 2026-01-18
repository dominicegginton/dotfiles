{ self, config, pkgs, hostname, tailnet, ... }:

with config.lib.topology;

{
  systemd.tmpfiles.rules = [ "d /etc/ssl/tailscale 0755 root root -" ];

  systemd.services.tailscale-cert = {
    description = "Generate Tailscale HTTPS certificate";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tailscale}/bin/tailscale cert --cert-file=/etc/ssl/tailscale/${hostname}.${tailnet}.crt --key-file=/etc/ssl/tailscale/${hostname}.${tailnet}.key ${hostname}.${tailnet}";
      User = "root";
      Group = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [ "--ssh" "--accept-dns" "--accept-routes" ];
    extraSetFlags = [ "--posture-checking=true" ];
    interfaceName = "tailscale0";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = self.outputs.lib.maintainers.dominicegginton.email;
  };

  environment.systemPackages = with pkgs; [ tailscale ];

  topology.self.interfaces.tailscale0 = {
    network = tailnet;
    type = "tailscale";
    icon = ../../assets/tailscale.svg;
    virtual = true;
    addresses = [ hostname "${hostname}.${tailnet}" ];
  };
}
