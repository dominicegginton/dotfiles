{ config, lib, ... }:

{
  # Configure the display manager for graphical login and session management.
  services.displayManager = {
    autoLogin.user = lib.mkDefault null;
    gdm.banner = lib.mkDefault config.services.getty.greetingLine;
  };
}
