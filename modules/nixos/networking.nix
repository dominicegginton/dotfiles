{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.networking;
in {
  options.modules.networking = {
    enable = mkEnableOption "networking";
    wireless = mkEnableOption "wireless";
    hostname = mkOption {type = types.str;};
  };

  config = mkIf cfg.enable rec {
    sops.secrets."wireless.env" = {};

    networking = rec {
      hostName = mkDefault cfg.hostname;
      useDHCP = mkDefault true;
      firewall = rec {
        enable = mkDefault true;
        checkReversePath = mkDefault true;
        trustedInterfaces = mkDefault ["tailscale0"];
        allowedTCPPorts = mkDefault [22];
      };
      wireless = mkIf cfg.wireless rec {
        enable = mkDefault true;
        fallbackToWPA2 = mkDefault true;
        userControlled.enable = mkDefault true;
        userControlled.group = "wheel";
        environmentFile = config.sops.secrets."wireless.env".path;
        networks."@home_uuid@".psk = "@home_psk@";
        networks."@burbage_uuid@".psk = "@burbage_psk@";
      };
    };

    programs.ssh.startAgent = mkDefault true;
    services.tailscale.enable = mkDefault true;
    services.openssh.enable = mkDefault true;
    environment.systemPackages = with pkgs; [tailscale];
  };
}
