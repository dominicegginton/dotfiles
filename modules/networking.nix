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

    boot.kernel.sysctl = {
      # increase the maximum connections
      # ihe upper limit on how many connections the kernel will accept (default 4096 since kernel version 5.6):
      "net.core.somaxconn" = 8192;
      # help prevent packet loss during high traffic periods.
      # defines the maximum number of packets that can be queued on the network device input queue.
      "net.core.netdev_max_backlog" = 65536;
      # default socket receive buffer size, improve network performance & applications that use sockets. adjusted for 8GB RAM.
      "net.core.rmem_default" = 1048576; # 1 MB
      # maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations - adjusted for 8GB RAM.
      "net.core.rmem_max" = 67108864; # 64 MB
      # default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 8GB RAM.
      "net.core.wmem_default" = 1048576; # 1 MB
      # maximum socket send buffer size - ajusted for 8GB RAM.
      "net.core.wmem_max" = 67108864; # 64 MB
      # reduce the chances of fragmentation
      "net.ipv4.ipfrag_high_threshold" = 5242880; # 5 MB
      # allow tcp window size to grow beyond its default maximum value.
      "net.ipv4.tcp_window_scaling" = 1;
      # define the memory reserved for TCP read operations.
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      # define the memory reserved for tcp write operations
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      # optimizes for low latency and high throughput
      "net.ipv4.tcp_congestion_control" = "bbr";
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
