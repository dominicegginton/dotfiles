{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  platform,
  stateVersion,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.dell-latitude-7390
    ./disks.nix
  ];

  swapDevices = [
    {device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2";}
  ];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.logind = {
    extraConfig = "HandlePowerKey=suspend";
    lidSwitch = "suspend";
  };

  hardware.mwProCapture.enable = true;

  modules.system.stateVersion = stateVersion;
  modules.system.nixpkgs.hostPlatform = platform;
  modules.system.nixpkgs.allowUnfree = true;
  modules.sops.enable = true;
  modules.networking.enable = true;
  modules.networking.hostname = hostname;
  modules.networking.ssh = true;
  modules.networking.tailscale = true;
  modules.networking.wireless = true;
  modules.virtualisation.enable = true;
  modules.virtualisation.vmVariant = true;
  modules.virtualisation.desktop = true;
  modules.bluetooth.enable = true;
  modules.users.users = ["dom"];
  modules.desktop.enable = true;
  modules.desktop.environment = "sway";
  modules.desktop.firefox = true;
  modules.desktop.packages = with pkgs; [
    thunderbird
    teams-for-linux
  ];
}
