{ config, lib, hostname, ... }:

with config.lib.topology;

{
  config = lib.mkIf (hostname != "residence-installer") {
    networking = {
      hostName = hostname;
      useDHCP = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
      firewall = {
        # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268078
        enable = lib.mkDefault true;
        trustedInterfaces = [ "tailscale0" ];
        checkReversePath = "loose";
        # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268158
        # extraCommands = ''
        #   ip46tables --append INPUT --protocol tcp --dport 22 --match hashlimit --hashlimit-name stig_byte_limit --hashlimit-mode srcip --hashlimit-above 1000000b/second --jump nixos-fw-refuse
        #   ip46tables --append INPUT --protocol tcp --dport 80 --match hashlimit --hashlimit-name stig_conn_limit --hashlimit-mode srcip --hashlimit-above 1000/minute --jump nixos-fw-refuse
        #   ip46tables --append INPUT --protocol tcp --dport 443 --match hashlimit --hashlimit-name stig_conn_limit --hashlimit-mode srcip --hashlimit-above 1000/minute --jump nixos-fw-refuse
        # '';
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

      # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268149
      timeServers = lib.mkDefault [
        "tick.usnogps.navy.mil"
        "tock.usnogps.navy.mil"
      ];
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
