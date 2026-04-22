{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.virtualisation.docker.enable {
    environment = {
      persistence."/persist".directories = lib.mkDefault [ "/var/lib/docker" ];
      systemPackages = with pkgs; [ docker ];
    };

    virtualisation.docker.autoPrune = {
      enable = lib.mkDefault true;
      flags = lib.mkDefault [ "--all" ];
      dates = lib.mkDefault "daily";
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
