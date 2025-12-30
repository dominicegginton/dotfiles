{ self, config, lib, pkgs, hostname, tailnet, ... }:

with config.lib.topology;

{
  config = lib.mkIf (hostname != "infector") {
    secrets.tailscale = "15536836-a306-471a-b64c-b27300c683ea";

    services = {
      tailscale = {
        enable = true;
        useRoutingFeatures = "both";
        authKeyFile = "/run/bitwarden-secrets/tailscale";
        authKeyParameters.ephemeral = true;
        extraUpFlags = [ "--ssh" "--accept-dns" ];
        extraSetFlags = [ "--posture-checking=true" ];
        interfaceName = "tailscale0";
      };
      tailscaleAuth.enable = true;
      davfs2.enable = true;
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
      addresses = [
        hostname
        "${hostname}.${tailnet}"
      ];
    };
  };
}
