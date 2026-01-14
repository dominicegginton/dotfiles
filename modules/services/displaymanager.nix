{ config, ... }:
{
  services.displayManager = {
    autoLogin.user = null;
    gdm.banner = config.services.getty.greetingLine;
  };
}
