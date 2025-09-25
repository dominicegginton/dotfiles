{ config, lib, ... }:

{
  config = {
    topology.self.interfaces.waydroid = lib.mkIf config.virtualisation.waydroid.enable {
      type = "bridge";
      virtual = true;
      addresses = [ "localhost" "127.0.0.1" ];
    };
  };
}

