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
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia_drm.modeset=1" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  environment.systemPackages = with pkgs; [ nvidia-vaapi-driver nvtopPackages.full egl-wayland libva-utils ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    prime.sync.enable = false;
    prime.offload.enable = true;
    prime.offload.enableOffloadCmd = true;
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:01:00:0";
  };

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
    users.dom.enable = true;
    display.enable = true;
    display.plasma.enable = true;
  };
}
