{ inputs, pkgs, config, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.msi-gs60
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-hdd
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    ./disks.nix
    ./boot.nix
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "kvm-intel" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia_drm.modeset=1" "nouveau.modeset=0" ];
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        intel-media-driver
      ];
    };
  };
  environment.variables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
  environment.systemPackages = with pkgs; [
    nvidia-vaapi-driver
    nvtopPackages.full
    egl-wayland
    libva
    libva-utils
    nvidia-offload
  ];
  hardware.nvidia = {
    modesetting.enable = true;
    # open = false;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    prime.reverseSync.enable = true;
    prime.offload.enable = false;
    prime.offload.enableOffloadCmd = true;
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:01:00:0";
  };

  # services.home-assistant = {
  #   enable = true;
  #   openFirewall = true;
  #   configDir = "/var/lib/hass";
  #   config = {
  #     homeassistant = {
  #       name = "Home";
  #     };
  #     config = { };
  #     lovelace = { mode = "yaml"; };
  #     logger = { default = "debug"; };
  #     http = { server_port = 8123; };
  #   };
  #   configWritable = true;
  #   lovelaceConfigWritable = true;
  #   lovelaceConfig = {
  #     title = "My Awesome Home";
  #     views = [
  #       {
  #         title = "Example";
  #         cards = [ ];
  #       }
  #     ];
  #   };
  # };
  #
  hardware.mwProCapture.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    services.networking.enable = true;
    services.networking.wireless = true;
    services.virtualisation.enable = true;
    services.bluetooth.enable = true;
    display.enable = true;
    display.plasma.enable = true;
    programs.steam.enable = true;
  };
}
