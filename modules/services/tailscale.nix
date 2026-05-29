{
  self,
  config,
  lib,
  pkgs,
  hostname,
  tailnet,
  ...
}:

with config.lib.topology;

let
  isWSL = config.wsl.enable;
  tailscaleInterface = if isWSL then "userspace-networking" else "tailscale0";
in
{
  # Ensure tailscale SSL directory exists
  systemd.tmpfiles.rules = [ "d /etc/ssl/tailscale 0755 root root -" ];

  # Auto-generate HTTPS certificates using Tailscale
  systemd.services.tailscale-cert =
    let
      notWSL = !isWSL;
    in
    lib.mkIf notWSL {
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

  # Tailscale service configuration
  services.tailscale = {
    enable = lib.mkForce true;
    useRoutingFeatures = lib.mkForce (if isWSL then "client" else "both");
    extraUpFlags = [
      "--ssh"
      "--accept-dns"
    ]
    ++ lib.optionals (!isWSL) [ "--accept-routes" ];
    extraSetFlags = [ "--posture-checking=true" ];
    interfaceName = lib.mkForce tailscaleInterface;
  };

  # ACME configuration for SSL certificates
  security.acme = {
    acceptTerms = lib.mkDefault true;
    defaults.email = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.email;
  };

  environment.systemPackages = with pkgs; [ tailscale ];

  # Topology metadata for Tailscale interface
  topology.self.interfaces.${tailscaleInterface} = {
    network = tailnet;
    type = "tailscale";
    icon = ../../assets/tailscale.svg;
    virtual = true;
    addresses = [
      hostname
      "${hostname}.${tailnet}"
    ];
  };
}
