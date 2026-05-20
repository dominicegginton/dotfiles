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

    environment.systemPackages = with pkgs; [ jetbrains.gateway ];

    programs.nix-ld.enable = lib.mkForce true;

    users.users.dom = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    programs.deadman.enable = lib.mkForce false;
    services = {
      smartd.enable = lib.mkForce false;
      thermald.enable = lib.mkForce false;
      upower.enable = lib.mkForce false;
      fwupd.enable = lib.mkForce false;
      fstrim.enable = lib.mkForce false;
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
