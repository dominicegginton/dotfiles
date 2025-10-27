{ config, lib, hostname, ... }:

with config.lib.topology;

{
  config = lib.mkIf (hostname != "residence-installer") {
    secrets.wireless = lib.mkIf config.networking.wireless.enable "04480e55-ca76-4444-a5cf-b242009fe153";
    networking = {
      hostName = hostname;
      useDHCP = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
      firewall = {
        enable = lib.mkDefault true;
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };
      wireless = lib.mkIf config.networking.wireless.enable {
        fallbackToWPA2 = true;
        userControlled.enable = true;
        userControlled.group = "wheel";
        secretsFile = "/run/bitwarden-secrets/wireless";
        networks = {
          "Home" = {
            pskRaw = "ext:psk_home";
            priority = 2;
          };
          "Burbage" = {
            pskRaw = "ext:psk_burbage";
            priority = 1;
          };
          "Dom's Pixel 9" = {
            pskRaw = "ext:psk_pixel9";
            priority = 1;
          };
          "Ribble" = {
            pskRaw = "ext:psk_ribble";
            priority = 0;
          };
        };
      };
      networkmanager = lib.mkIf config.networking.networkmanager.enable {
        dns = "systemd-resolved";
        unmanaged = [ "wlp108s0" ];
        # wifi.backend = "iwd";
      };
    };

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
          (mkConnection "router" "wlan0")
          (mkConnection "pixel-9" "hotspot")
        ];
      };
    };
  };
}
