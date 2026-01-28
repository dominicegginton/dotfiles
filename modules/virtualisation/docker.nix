{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.virtualisation.docker.enable {
    environment = {
      persistence."/persist".directories = [ "/var/lib/docker" ];
      systemPackages = with pkgs; [ docker ];
    };

    virtualisation.docker.autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "daily";
    };

    topology.self.interfaces.docker = {
      type = "bridge";
      virtual = true;
      addresses = [
        "localhost"
        "127.0.0.1"
      ];
    };
  };
}
