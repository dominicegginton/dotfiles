{ config, lib, ... }:

{
  options.services.clamav.enable = lib.mkEnableOption "clamav";

  # ClamAV Service Configuration
  config.services.clamav = lib.mkIf config.services.clamav.enable {
    clamonacc.enable = lib.mkDefault true;
    scanner.enable = lib.mkDefault true;
    updater.enable = lib.mkDefault true;
    daemon.enable = lib.mkDefault true;
  };
}
