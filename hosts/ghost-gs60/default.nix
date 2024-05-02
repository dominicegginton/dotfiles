{
  inputs,
  pkgs,
  hostname,
  platform,
  stateVersion,
  ...
}: {
  imports = [];

  swapDevices = [
    {device = "";}
  ];

  boot = {
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
    desktop.packages = with pkgs; [];
  };
}
