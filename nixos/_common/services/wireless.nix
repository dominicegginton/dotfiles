{ config, ... }:

{
  sops.secrets.home_wifi_psk = { };

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    userControlled.group = "wheel";
    fallbackToWPA2 = true;
    networks.Home.psk = config.sops.secrets.home_wifi_psk.path;
    networks.Home.authProtocols = [ "WPA-PSK" ];
  };
}
