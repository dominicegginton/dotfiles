{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.wsl.enable {
    wsl = {
      # Default user for WSL environment
      defaultUser = "dom";

      # Use Windows drivers for better hardware compatibility and performance
      useWindowsDriver = lib.mkForce true;
    };

    environment.systemPackages = with pkgs; [ jetbrains.gateway ];

    # Disable kernel module locking in WSL as it prevents Docker port mapping
    security.lockKernelModules = lib.mkForce false;
    security.protectKernelImage = lib.mkForce false;

    # Enable nix-ld to run unpatched Linux binaries
    programs.nix-ld.enable = lib.mkForce true;

    security.run0.wheelNeedsPassword = lib.mkForce false;
    users.users.dom = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    # Disable security services not applicable to WSL
    programs.deadman.enable = lib.mkForce false;
    services.usbguard.enable = lib.mkForce false;

    services = {
      # Disable thermal and power management not required in WSL
      thermald.enable = lib.mkForce false;
      upower.enable = lib.mkForce false;

      # Disable firmware updates
      fwupd.enable = lib.mkForce false;

      # Disable storage maintenance for virtualized disks
      fstrim.enable = lib.mkForce false;
      smartd.enable = lib.mkForce false;
    };

    boot = {
      loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
      };

      # Disable Plymouth bootloader splash screen in WSL.
      plymouth.enable = lib.mkForce false;
    };
  };
}
