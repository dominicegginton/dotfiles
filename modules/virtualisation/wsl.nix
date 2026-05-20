{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.wsl.enable {
    wsl = {
      # Configure the default user for WSL and enable the use of Windows drivers for better hardware compatibility and performance when running NixOS in a WSL environment.
      defaultUser = "dom";

      # Configure WSL to use Windows drivers for better hardware compatibility and performance when running NixOS in a WSL environment.
      # This allows NixOS to leverage the underlying Windows hardware support, improving performance and compatibility for various devices and peripherals.
      useWindowsDriver = lib.mkForce true;
    };

    environment.systemPackages = with pkgs; [ jetbrains.gateway ];

    # Enable nix-ld to allow running Linux binaries in WSL without needing to recompile them for the WSL environment,
    # improving compatibility and ease of use when running Linux applications in WSL.
    programs.nix-ld.enable = lib.mkForce true;

    security.run0.wheelNeedsPassword = lib.mkForce false;
    users.users.dom = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    # Disable deadman and usbguard security programs and services.
    programs.deadman.enable = lib.mkForce false;
    services.usbguard.enable = lib.mkForce false;

    services = {
      # Disable thermald and upower, thermal and power management not required in WSL environments.
      thermald.enable = lib.mkForce false;
      upower.enable = lib.mkForce false;

      # Disable fwupd as firmware updates are not applicable within WSL environments.
      fwupd.enable = lib.mkForce false;

      # Disable fstrim and smartd in WSL environments as storage is virtualized.
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
