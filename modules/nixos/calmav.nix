{ config, lib, ... }:

{
  options.security.clamav.enable = lib.mkEnableOption "clamav";

  config.services.clamav = lib.mkIf config.security.clamav.enable {
    scanner.enable = true;
    updater.enable = true;
    daemon.enable = true;
  };
}

