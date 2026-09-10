{
  self,
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.wsl;
in

{
  config = lib.mkIf cfg.enable {
    # Apply the WSL overlay to add WSL-specific configurations and packages
    nixpkgs.overlays = [ self.outputs.overlays.wsl ];

    # Register binfmt_misc handler for Windows binaries (.exe)
    wsl.interop.register = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      xdg-utils
      wsl-open
    ];

    # Disable kernel module locking in WSL as it prevents Docker port mapping
    security = {
      lockKernelModules = lib.mkForce false;
      protectKernelImage = lib.mkForce false;
      run0.enable = lib.mkForce false;
      sudo.wheelNeedsPassword = lib.mkForce false;
    };

    # Enable nix-ld to run unpatched Linux binaries
    programs.nix-ld.enable = lib.mkForce true;

    users.users.${cfg.defaultUser} = {
      hashedPasswordFile = lib.mkForce null;
      initialPassword = "";
    };

    # Disable security services not applicable to WSL
    programs.deadman.enable = lib.mkForce false;
    services.usbguard.enable = lib.mkForce false;

    services = {
      # Disable power and thermal management services - Handled by the Windows host.
      thermald.enable = lib.mkForce false;
      upower.enable = lib.mkForce false;

      # Disable firmware updates.
      fwupd.enable = lib.mkForce false;

      # Disable storage maintenance for disks in WSL.
      fstrim.enable = lib.mkForce false;
      smartd.enable = lib.mkForce false;
    };

    # Disable wireless networking - Networking is handled by the windows host in WSL.
    networking.wireless.enable = lib.mkForce false;

    # Avoid boot/login delays from network-online waits in WSL networking.
    systemd.services = {
      NetworkManager-wait-online.enable = lib.mkForce false;
      systemd-networkd-wait-online.enable = lib.mkForce false;
      wpa_supplicant.enable = lib.mkForce false;
    };

    boot = {
      # Disable bootloader in WSL - Windows host handles booting.
      loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = lib.mkForce false;
      };

      # Disable Plymouth bootloader splash screen - No graphical boot in WSL.
      plymouth.enable = lib.mkForce false;
    };
  };
}
