{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.virtualisation.docker.enable {
    users.users.dom.extraGroups = [ "docker" ];

    environment.persistence."/persist".directories = [ "/var/lib/docker" ];

    virtualisation.docker.autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "daily";
    };

    topology.self.interfaces.docker = {
      type = "bridge";
      virtual = true;
      addresses = [ "localhost" "127.0.0.1" ];
    };
  };
}

