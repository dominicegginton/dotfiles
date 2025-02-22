{ config, lib, pkgs, hostname, ... }:

with lib;
with config.lib.topology;

{
  options.modules.networking.wireless.enable = mkEnableOption "wireless";

  config = {
    modules.secrets.wireless = "04480e55-ca76-4444-a5cf-b242009fe153";
    modules.secrets.tailscale = "15536836-a306-471a-b64c-b27300c683ea";
    networking = {
      hostName = hostname;
      useDHCP = true;
      wireless = mkIf config.modules.networking.wireless.enable {
        enable = true;
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
        };
      };
    };
    topology.self.interfaces.wlan0 = {
      network = "quardon";
      physicalConnections = [
        (mkConnection "quardon-unifi-ap-dom" "wlan0")
        (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
        (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
      ];
      type = "wifi";
    };
    services.openssh.enable = true;
    programs.ssh.startAgent = true;

    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      interfaceName = "userspace-networking";
    };
    systemd.services.tailscale-autoconnect = {
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        PATH=${with pkgs; makeBinPath [ tailscale ]}
        tailscale up --reset --ssh --accept-dns --auth-key /run/bitwarden-secrets/tailscale
      '';
    };
    environment.systemPackages = with pkgs; [ tailscale ];
    topology.self.interfaces.tailscale = {
      network = "tailscale";
      virtual = true;
    };

  };
}
