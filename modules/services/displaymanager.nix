{ config, lib, ... }:
{
  services.displayManager = {
    autoLogin.user = lib.mkDefault null;
    gdm.banner = lib.mkDefault config.services.getty.greetingLine;
  };
}
