{ lib, config, pkgs, ... }:

{
  config = lib.mkIf config.services.unifi.enable {
    services.unifi.openFirewall = true;
    services.unifi.unifiPackage = pkgs.unifi;
    services.unifi.mongodbPackage = pkgs.mongodb-7_0;
  };
}
