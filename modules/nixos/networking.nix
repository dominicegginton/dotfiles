{ config, lib, pkgs, hostname, tailnet, ... }:

with config.lib.topology;

{
  config = {
    secrets.wireless = lib.mkIf config.networking.wireless.enable "04480e55-ca76-4444-a5cf-b242009fe153";
    secrets.tailscale = "15536836-a306-471a-b64c-b27300c683ea";
    networking = {
      hostName = hostname;
      useDHCP = lib.mkDefault true;
      firewall = {
        enable = true;
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };
      nftables.enable = true;
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        unmanaged = [ "lo" "wlp108s0" ];
      };
      wireless = lib.mkIf config.networking.wireless.enable {
        fallbackToWPA2 = true;
        userControlled.enable = true;
        userControlled.group = "wheel";
        secretsFile = "/run/bitwarden-secrets/wireless";
        networks = {
          "Home" = {
            pskRaw = "ext:psk_home";
            priority = 0;
          };
          "Burbage" = {
            pskRaw = "ext:psk_burbage";
            priority = 1;
          };
          "Ribble" = {
            pskRaw = "ext:psk_ribble";
            priority = 2;
          };
        };
      };
    };
    services.openssh.enable = true;
    programs.ssh.startAgent = true;
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = "/run/bitwarden-secrets/tailscale";
      authKeyParameters.ephemeral = true;
      extraUpFlags = [ "--ssh" "--accept-dns" ];
      extraSetFlags = [ "--posture-checking=true" ];
      interfaceName = "tailscale0";
    };
    services.tailscaleAuth.enable = true;
    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@${hostname}.dominicegginton.dev";
    };
    services.davfs2.enable = true;
    environment.systemPackages = with pkgs; [ tailscale ];
    topology.self.interfaces = {
      lo = {
        type = "loopback";
        virtual = true;
        addresses = [ "localhost" "127.0.0.1" ];
      };
      wlp108s0 = lib.mkIf config.networking.wireless.enable {
        type = "wifi";
        addresses = [ hostname ];
        physicalConnections = [
          (mkConnection "quardon-ap-downstairs" "wlan0")
          (mkConnection "quardon-ap-upstairs" "wlan0")
          (mkConnection "ribble-router" "wlan0")
        ];
      };
      tailscale0 = {
        network = tailnet;
        type = "tailscale";
        icon = ../../assets/tailscale.svg;
        virtual = true;
        addresses = [ hostname "${hostname}.${tailnet}" ];
      };
    };
  };
}
