{ pkgs, ... }:

{
  config = {
    security.sudo.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;
    services.clamav.scanner.enable = true;
    services.clamav.updater.enable = true;
    services.clamav.daemon.enable = true;
    environment.systemPackages = with pkgs; [ clamav ];
  };
}
