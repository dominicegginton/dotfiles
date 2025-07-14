{ lib, config, pkgs, hostname, ... }:

{
  config = lib.mkIf config.services.unifi.enable {
    services.unifi = {
      unifiPackage = pkgs.unifi;
      mongodbPackage = pkgs.mongodb-7_0;
      openFirewall = true;
    };
    topology.self.services.unifi = {
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
