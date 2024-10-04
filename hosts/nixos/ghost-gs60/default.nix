{ inputs, pkgs, config, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in

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
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia_drm.modeset=1" "nouveau.modeset=0" ];
  # hardware.graphics.enable = true;
  # hardware.graphics.enable32Bit = true;
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

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    configDir = "/var/lib/hass";
    config = {
      homeassistant = {
        name = "Home";
      };
      config = { };
      lovelace = { mode = "yaml"; };
      logger = { default = "debug"; };
      http = { server_port = 8123; };
    };
    configWritable = true;
    lovelaceConfigWritable = true;
    lovelaceConfig = {
      title = "My Awesome Home";
      views = [
        {
          title = "Example";
          cards = [ ];
        }
      ];
    };
  };

  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi8;
    mongodbPackage = pkgs.mongodb-6_0;
  };
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-6_0;
  };
  networking.firewall.allowedTCPPorts = [ 8443 ];


  hardware.mwProCapture.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  services.logind.extraConfig = "HandlePowerKey=suspend";
  services.logind.lidSwitch = "suspend";

  modules = {
    services.networking.enable = true;
    services.networking.hostname = "ghost-gs60";
    services.networking.wireless = true;
    services.virtualisation.enable = true;
    services.ssh.enable = true;
    services.bluetooth.enable = true;
    services.syncthing.enable = true;
    services.steam.enable = true;
    display.enable = true;
    display.plasma.enable = true;
  };
}
