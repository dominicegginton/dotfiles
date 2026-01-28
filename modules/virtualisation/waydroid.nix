{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.virtualisation.waydroid.enable {
    environment.systemPackages = with pkgs; [
      waydroid
      waydroid-helper
      android-tools
      unzip
    ];

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
