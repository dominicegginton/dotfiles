{ config, ... }:

{
  sops.secrets.home_wifi_psk = {};

  networking.wireless = {
    enable = true;
    userControlled = {
      enable = true;
      group = "wheel";
    };
    networks = {
      "Home".psk = config.sops.secrets.home_wifi_psk.path;
    };
  };
}
