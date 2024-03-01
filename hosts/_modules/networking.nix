{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.networking;
  inherit (pkgs.stdenv) isLinux;
in {
  options.modules.networking = {
    enable = mkEnableOption "enable networking";

    hostname = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostname of the system";
    };

    wireless = mkOption {
      type = types.bool;
      default = false;
      description = "Enable wireless networking";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."wireless.env" = {};

    networking.hostName = cfg.hostname;
    networking.useDHCP = mkDefault true;

    networking.wireless = mkIf cfg.wireless {
      enable = true;
      userControlled.enable = true;
      userControlled.group = "wheel";
      fallbackToWPA2 = true;
      environmentFile = config.sops.secrets."wireless.env".path;
      networks."@home_uuid@".psk = "@home_psk@";
      networks."@burbage_uuid@".psk = "@burbage_psk@";
    };
  };
}
