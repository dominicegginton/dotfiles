{ config, lib, pkgs, ... }:

{
  config.services.mosquitto = lib.mkIf config.services.mosquitto.enable {
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
}


