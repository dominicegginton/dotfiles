{
  inputs,
  pkgs,
  hostname,
  platform,
  stateVersion,
  config,
  lib,
  ...
}: with lib; {
  imports = [
    inputs.nixos-hardware.nixosModules.msi-gs60
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c0a9248d-dff0-427e-8e87-cbb04c5de1fd";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/714A-640B";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/8edf9107-5ea5-427a-803a-c34731886c52";}
  ];

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

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    prime = {
      sync.enable = true;
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

  modules = rec {
    nixos.stateVersion = stateVersion;
    nixos.nixpkgs.hostPlatform = platform;
    nixos.nixpkgs.allowUnfree = true;
    nixos.nixpkgs.permittedInsecurePackages = [
      "libav-11.12" # for mmfm
      "mupdf-1.17.0" # for mmfm
    ];
    networking.enable = true;
    networking.hostname = "ghost-gs60";
    networking.wireless = true;
    virtualisation.enable = true;
    bluetooth.enable = true;
    users.dom.enable = true;
    desktop.sway.enable = true;
    desktop.gamescope.enable = true;
    desktop.packages = with pkgs; [];
  };
}
