{ config, ... }:
{
  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268172
  services.displayManager.autoLogin.user = null;

  # set the banner to be the same as the getty greeting 
  services.xserver.displayManager.gdm.banner = config.services.getty.greetingLine;
}
