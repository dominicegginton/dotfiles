{
  inputs,
  pkgs,
  hostname,
  platform,
  stateVersion,
  ...
}: {
  imports = [inputs.nixos-hardware.nixosModules.dell-latitude-7390];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2d59d3c7-44f3-4fd3-9c7a-64b2ec9f21a0";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8543-16DB";
    fsType = "vfat";
  };
  swapDevices = [
    {device = "/dev/disk/by-uuid/4e74fa9d-47d7-4a43-9cec-01d4fdd1a1a2";}
  ];

  boot = rec {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "sd_mod"];
    kernelModules = ["kvm-intel"];
    binfmt.emulatedSystems = [
      "wasm32-wasi"
      "x86_64-windows"
      "aarch64-linux"
      "armv7l-linux"
      "riscv32-linux"
      "riscv64-linux"
    ];
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
    networking.hostname = "latitude-8390";
    networking.wireless = true;
    virtualisation.enable = true;
    bluetooth.enable = true;
    users.dom.enable = true;
    desktop.sway.enable = true;
    desktop.packages = with pkgs; [
      thunderbird
      teams-for-linux
      chromium
    ];
  };
}
