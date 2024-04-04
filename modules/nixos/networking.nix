{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.networking;
in {
  options.modules.networking = {
    enable = mkEnableOption "networking";
    wireless = mkEnableOption "wireless";

    hostname = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostname of the system";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."wireless.env" = {};

    networking.hostName = cfg.hostname;
    networking.useDHCP = mkDefault true;
    networking.firewall = mkIf isLinux {
      enable = true;
      checkReversePath = true;
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [22];
    };
    networking.wireless = mkIf (isLinux && cfg.wireless) {
      enable = true;
      userControlled.enable = true;
      userControlled.group = "wheel";
      fallbackToWPA2 = true;
      environmentFile = config.sops.secrets."wireless.env".path;
      networks."@home_uuid@".psk = "@home_psk@";
      networks."@burbage_uuid@".psk = "@burbage_psk@";
    };

    programs.ssh = mkIf isLinux {
      startAgent = true;
      extraConfig = ''
        host i-* mi-*
        ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"
      '';
    };
    services.openssh = mkIf isLinux {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = mkDefault "no";
    };
    services.sshguard = mkIf isLinux {
      enable = true;
      whitelist = [];
    };

    services.tailscale.enable = true;
    environment.systemPackages = with pkgs;
      [tailscale]
      ++ optionals (cfg.wireless && config.modules.desktop.enable) [
        pkgs.wpa_supplicant_gui
      ];
  };
}
