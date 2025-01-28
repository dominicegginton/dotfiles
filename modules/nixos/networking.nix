{ config, lib, pkgs, hostname, ... }:

with lib;

{
  options.modules.networking.wireless.enable = mkEnableOption "wireless";

  config = {
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
          "Pixel6a" = {
            pskRaw = "ext:psk_pixel6a";
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
      interfaceName = "userspace-networking";
    };
    systemd.services.tailscale-autoconnect = {
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        PATH=${with pkgs; makeBinPath [ tailscale ]}
        tailscale up --ssh --accept-dns --auth-key /run/bitwarden-secrets/tailscale
      '';
    };
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
