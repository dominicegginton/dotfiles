{ config, lib, ... }:

{
  config.services.pipewire = lib.mkIf config.services.pipewire.enable {
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
