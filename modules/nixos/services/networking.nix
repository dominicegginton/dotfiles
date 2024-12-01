{ config, lib, pkgs, hostname, ... }:

let
  cfg = config.modules.services.networking;
in

with lib;

{
  options.modules.services.networking = {
    enable = mkEnableOption "networking";
    wireless = mkEnableOption "wireless";
  };

  config = mkIf cfg.enable {
    sops.secrets."wireless.env" = { };


    networking = {
      hostName = hostname;
      useDHCP = true;
      wireless = mkIf cfg.wireless {
        enable = true;
        fallbackToWPA2 = true;
        userControlled.enable = true;
        userControlled.group = "wheel";
        secretsFile = config.sops.secrets."wireless.env".path;
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
      description = "Automatic connection to Tailscale";
      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = with pkgs; ''
        sleep 2
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then
          exit 0
        fi
        ${tailscale}/bin/tailscale up
      '';
    };
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
