{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation;
in {
  options.modules.virtualisation = {
    enable = mkEnableOption "Enable virtualisation support";
    vmVariant = mkEnableOption "Enable VM Variant";
    desktop = mkEnableOption "Enable desktop virtualisation tools";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        defaultNetwork.settings.dns_enabled = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        enable = true;
        enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
      };

      vmVariant = mkIf cfg.vmVariant {
        users.groups.nixosvmtest = {};
        users.users.nixvmtest = {
          description = "NixOS Test User";
          isNormalUser = true;
          initialPassword = "test";
          group = "nixosvmtest";
        };

        virtualisation.graphics = mkIf cfg.desktop true;
      };
    };

    environment.systemPackages = with pkgs; [
      qemu # Virtualisation platform
    ];
  };
}
