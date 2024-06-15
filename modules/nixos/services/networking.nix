{ config
, lib
, pkgs
, ...
}:

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
    services.tailscale.enable = mkDefault true;
    services.openssh.enable = mkDefault true;
    environment.systemPackages = with pkgs; [ tailscale ];
  };
}
