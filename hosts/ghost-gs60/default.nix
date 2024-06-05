{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.msi-gs60
    ./disks.nix
    ./boot.nix
  ];

  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      intel-media-driver
      libvdpau-va-gl
      nvidia-vaapi-driver
      vaapiIntel
      vaapiVdpau
      vulkan-validation-layers
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware.mwProCapture.enable = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    nixos.stateVersion = stateVersion;
    nixos.role = "server";
    services.deluge.enable = true;
    services.plex.enable = true;
    services.unifi.enable = true;
    networking.enable = true;
    networking.hostname = "ghost-gs60";
    virtualisation.enable = true;
    users.dom.enable = true;
    desktop.packages = with pkgs; [];
  };
}
