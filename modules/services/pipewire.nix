{ config, lib, ... }:

{
  config.services.pipewire = lib.mkIf config.services.pipewire.enable {
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    jack.enable = lib.mkDefault true;
    wireplumber.enable = lib.mkDefault true;
  };
}
