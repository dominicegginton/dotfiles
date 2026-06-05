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
  notWSL = !config.wsl.enable;
  tailscaleInterface = if notWSL then "tailscale0" else "userspace-networking";
in

{
  # Ensure tailscale SSL directory exists
  systemd.tmpfiles.rules = [ "d /etc/ssl/tailscale 0755 root root -" ];

  # Auto-generate HTTPS certificates using Tailscale
  systemd.services.tailscale-cert = lib.mkIf notWSL {
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

  # tsnsrv configuration
  services.tsnsrv = {
    enable = lib.mkDefault true;
    defaults.authKeyPath = config.sops.secrets."services/tsnsrv/auth-key".path;
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
