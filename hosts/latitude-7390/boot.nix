_:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "vhost_vsock" ];
  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "x86_64-windows"
    "aarch64-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];
}
