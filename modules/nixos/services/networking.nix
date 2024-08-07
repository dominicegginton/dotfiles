{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.networking;
in

with lib;

{
  options.modules.services.networking = {
    enable = mkEnableOption "networking";
    wireless = mkEnableOption "wireless";
    hostname = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    sops.secrets."wireless.env" = { };

    networking = {
      hostName = mkDefault cfg.hostname;
      useDHCP = mkDefault true;
      nftables.enable = mkDefault true;
      firewall = {
        enable = mkDefault true;
        checkReversePath = mkDefault true;
        trustedInterfaces = mkDefault [ "tailscale0" ];
        allowedTCPPorts = mkDefault [ 22 ];
      };
      wireless = mkIf cfg.wireless {
        enable = mkDefault true;
        fallbackToWPA2 = mkDefault true;
        userControlled.enable = mkDefault true;
        userControlled.group = "wheel";
        environmentFile = config.sops.secrets."wireless.env".path;
        networks."@home_uuid@".psk = "@home_psk@";
        networks."@burbage_uuid@".psk = "@burbage_psk@";
        networks."@pixel_uuid@".psk = "@pixel_psk@";
      };
    };

    programs.ssh.startAgent = mkDefault true;
    services.tailscale = mkIf cfg.enable {
      enable = mkDefault true;
      useRoutingFeatures = "both";
      interfaceName = mkDefault "userspace-networking";
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
    services.openssh.enable = mkDefault true;
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
