{ lib, config, pkgs, hostname, ... }:

{
  config = lib.mkIf config.services.unifi.enable {
    services.unifi.openFirewall = true;
    services.unifi.unifiPackage = pkgs.unifi;
    services.unifi.mongodbPackage = pkgs.mongodb-7_0;
    topology.self.services.homepage-dashboard = {
      name = "Unifi";
      icon = ./../../assets/unifi.svg;
      details = {
        listen = {
          text = "${hostname}:8080 - ${hostname}:8843";
        };
      };
    };
  };
}
