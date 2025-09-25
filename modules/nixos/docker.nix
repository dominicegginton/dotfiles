{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.virtualisation.docker.enable {
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

