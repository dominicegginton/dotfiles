{ config, lib, hostname, ... }:

with config.lib.topology;

{
  config = lib.mkIf (hostname != "residence-installer") {
    networking = {
      hostName = hostname;
      useDHCP = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
      firewall = {
        enable = lib.mkDefault true;
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
      };
      wireless = {
        fallbackToWPA2 = true;
        userControlled.enable = true;
        userControlled.group = "wheel";
        iwd = {
          enable = true;
          settings = {
            IPv6.Enabled = true;
            Settings.AutoConnect = true;
            General.PowerSave = false;
          };
        };
      };

      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        unmanaged = [ "wlp108s0" ];
        wifi = {
          backend = "iwd";
          powersave = false;
        };
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
