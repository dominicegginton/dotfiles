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
    ssh = mkEnableOption "ssh";
    tailscale = mkEnableOption "tailscale";
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
      checkReversePath = mkIf cfg.tailscale true;
      trustedInterfaces =
        []
        ++ (
          if cfg.tailscale
          then ["tailscale0"]
          else []
        );
      allowedTCPPorts =
        []
        ++ (
          if cfg.ssh
          then [22]
          else []
        );
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

    programs.ssh.startAgent = mkIf (isLinux && cfg.ssh) true;
    services.openssh = mkIf (isLinux && cfg.ssh) {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = mkDefault "no";
    };
    services.sshguard = mkIf (isLinux && cfg.ssh) {
      enable = true;
      whitelist = [];
    };

    services.tailscale.enable = mkIf cfg.tailscale true;
    environment.systemPackages =
      []
      ++ optionals cfg.tailscale [
        pkgs.tailscale # Tailscale CLI
      ]
      ++ optionals (cfg.wireless && config.modules.desktop.enable) [
        pkgs.wpa_supplicant_gui # GUI for WPA supplicant
      ];
  };
}
