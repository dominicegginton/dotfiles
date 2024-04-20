{
  inputs,
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

  services.logind = {
    extraConfig = "HandlePowerKey=suspend";
    lidSwitch = "suspend";
  };

  hardware.mwProCapture.enable = true;

  modules.system.stateVersion = stateVersion;
  modules.system.nixpkgs.hostPlatform = platform;
  modules.system.nixpkgs.allowUnfree = true;
  modules.networking.enable = true;
  modules.networking.hostname = hostname;
  modules.networking.wireless = true;
  modules.bluetooth.enable = true;
  modules.users.users = ["dom"];
  modules.desktop.enable = false;
  modules.desktop.environment = "";
  modules.desktop.packages = with pkgs; [];
}
