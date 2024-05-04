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
    boot.kernel.sysctl = rec {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
    networking.hostName = cfg.hostname;
    networking.useDHCP = mkDefault true;
    services.tailscale.enable = true;
    networking.firewall = rec {
      enable = true;
      checkReversePath = true;
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [22];
    };
    networking.wireless = mkIf cfg.wireless rec {
      enable = true;
      userControlled.enable = true;
      userControlled.group = "wheel";
      fallbackToWPA2 = true;
      environmentFile = config.sops.secrets."wireless.env".path;
      networks."@home_uuid@".psk = "@home_psk@";
      networks."@burbage_uuid@".psk = "@burbage_psk@";
    };
    programs.ssh = rec {
      startAgent = true;
      extraConfig = ''
        host i-* mi-*
        ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"
      '';
    };
    services.openssh = rec {
      enable = true;
      settings.PasswordAuthentication = mkDefault false;
      settings.PermitRootLogin = mkDefault "no";
    };
    environment.systemPackages = with pkgs; [tailscale];
  };
}
