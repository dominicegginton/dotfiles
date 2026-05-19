{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.wsl.enable or false) {
    wsl = {
      defaultUser = "dom";
      useWindowsDriver = lib.mkForce true;
    };

    environment.systemPackages = [
      pkgs.wget
      pkgs.jetbrains.gateway
    ];

    programs.nix-ld.enable = true;

    users.users.dom = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    security.run0.wheelNeedsPassword = lib.mkForce false;

    boot = {
      loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
      };
      plymouth.enable = lib.mkForce false;
    };
  };
}
