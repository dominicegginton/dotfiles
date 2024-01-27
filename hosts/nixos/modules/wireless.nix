{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.wireless;
in {
  options.modules.wireless.enable = mkEnableOption "enable wireless support";

  config = mkIf cfg.enable {
    sops.secrets."wireless.env" = {};

    networking.wireless = {
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
