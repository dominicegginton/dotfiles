{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.docker;
in

{
  config = lib.mkIf cfg.enable {
    # Container runtime requires user namespaces for rootless containers/sandboxing
    boot.kernel.sysctl."user.max_user_namespaces" = lib.mkDefault 10000;

    environment = {
      persistence."/persist".directories = lib.mkIf config.impermanence.enable [ "/var/lib/docker" ];
      systemPackages = with pkgs; [ docker ];
    };

    # Automatic pruning of unused Docker resources
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
