{ config, lib, hostname, ... }:

with config.lib.topology;

{
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    nftables.enable = lib.mkDefault true;
    firewall = {
      enable = lib.mkDefault true;
      trustedInterfaces = lib.mkDefault [ "tailscale0" ];
      checkReversePath = lib.mkDefault "loose";
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

    timeServers = lib.mkDefault [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
  };

  topology.self.interfaces = {
    lo = {
      type = "loopback";
      virtual = true;
      addresses = [ "localhost" "127.0.0.1" ];
    };
    wlp108s0 = lib.mkIf config.networking.wireless.iwd.enable {
      type = "wifi";
      addresses = [ hostname ];
      physicalConnections = [
        (mkConnection "router" "wlan0")
        (mkConnection "pixel-9" "hotspot")
      ];
    };
  };
}
