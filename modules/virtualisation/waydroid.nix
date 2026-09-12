{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.waydroid;
in

{
  config = lib.mkIf cfg.enable {
    # Waydroid container runtime requires user namespaces
    boot.kernel.sysctl."user.max_user_namespaces" = lib.mkDefault 10000;

    environment.systemPackages = with pkgs; [
      waydroid
      waydroid-helper
      android-tools
      unzip
    ];

    # Persistent storage for Waydroid
    environment.persistence."/persist" = lib.mkIf config.impermanence.enable {
      directories = [ "/var/lib/waydroid" ];
      users.dom.directories = [ ".local/share/waydroid" ];
    };

    # Network bridge for Waydroid
    topology.self.interfaces.waydroid = {
      type = "bridge";
      virtual = true;
      addresses = [
        "localhost"
        "127.0.0.1"
      ];
    };
  };
}
