{ config, lib, ... }:

let
  cfg = config.services.clamav;
in

{
  options.services.clamav.enable = lib.mkEnableOption "clamav";

  # ClamAV Service Configuration
  config = {
    services.clamav = lib.mkIf cfg.enable {
      clamonacc.enable = lib.mkDefault true;
      scanner.enable = lib.mkDefault true;
      updater.enable = lib.mkDefault true;
      daemon.enable = lib.mkDefault true;
    };

    # Persistent storage for ClamAV virus signatures
    environment.persistence."/persist".directories =
      lib.mkIf (config.impermanence.enable && cfg.enable)
        [
          "/var/lib/clamav"
        ];
  };
}
