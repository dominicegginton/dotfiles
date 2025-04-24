{ config, lib, pkgs, hostname, tailnet, ... }:

with lib;
with config.lib.topology;

{
  options.modules.networking = {
    wireless.enable = mkEnableOption "wireless";
    tailscale = { };
  };

  config = {
    modules.secrets.wireless = "04480e55-ca76-4444-a5cf-b242009fe153";
    modules.secrets.tailscale = "15536836-a306-471a-b64c-b27300c683ea";
    networking = {
      hostName = hostname;
      useDHCP = true;
      firewall.enable = true;
      nftables.enable = true;
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
          "Ribble" = {
            pskRaw = "ext:psk_ribble";
            priority = 2;
          };
        };
      };
    };
    topology.self.interfaces = {
      wlan0-quardon = mkIf config.modules.networking.wireless.enable {
        network = "quardon";
        type = "wifi";
        physicalConnections = [
          (mkConnection "quardon-unifi-ap-dom" "wlan0")
          (mkConnection "quardon-unifi-ap-downstairs" "wlan0")
          (mkConnection "quardon-unifi-ap-upstairs" "wlan0")
        ];
      };
      wlan0-ribble = mkIf config.modules.networking.wireless.enable {
        network = "ribble";
        type = "wifi";
        physicalConnections = [ (mkConnection "ribble-unifi-ap" "wlan0") ];
      };
    };
    services.openssh.enable = true;
    programs.ssh.startAgent = true;
    services.tailscaleAuth.enable = true;
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "both";
      authKeyFile = "/run/bitwarden-secrets/tailscale";
      authKeyParameters.ephemeral = true;
      extraUpFlags = [ "--ssh" "--accept-dns" ];
      extraSetFlags = [ "--posture-checking=true" ];
      interfaceName = "tailscale0";
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.checkReversePath = "loose";
    services.nginx.tailscaleAuth.virtualHosts = [
      "dash.${hostname}"
      "frigate.${hostname}"
      "ha.${hostname}"
    ];
    environment.systemPackages = with pkgs; [ tailscale ];
    topology.self.interfaces.tailscale0 = {
      network = tailnet;
      type = "tailscale";
      icon = ../../assets/tailscale.svg;
      virtual = true;
    };
  };
}
