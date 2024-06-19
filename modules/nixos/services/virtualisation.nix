{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.services.virtualisation;
in

with lib;

{
  options.modules.services.virtualisation.enable = mkEnableOption "virtualisation";

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        defaultNetwork.settings.dns_enabled = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        enable = true;
        enableNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
      };

      vmVariant = {
        users.groups.nixosvmtest = { };
        users.users.nix = {
          description = "NixOS VM Test User";
          isNormalUser = true;
          initialPassword = "";
          group = "nixosvmtest";
        };
      };
    };

    environment.systemPackages = with pkgs; [ qemu ];
  };
}
