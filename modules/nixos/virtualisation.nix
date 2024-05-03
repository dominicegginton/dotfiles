{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation;
in {
  options.modules.virtualisation.enable = mkEnableOption "virtualisation";

  config = mkIf cfg.enable rec {
    virtualisation = rec {
      podman = rec {
        defaultNetwork.settings.dns_enabled = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        enable = true;
        enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
      };

      vmVariant = rec {
        users.groups.nixosvmtest = rec {};
        users.users.nix = rec {
          description = "NixOS VM Test User";
          isNormalUser = true;
          initialPassword = "";
          group = "nixosvmtest";
        };
      };
    };

    environment.systemPackages = with pkgs; [qemu];
  };
}
