{ self, lib, config, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  imports = with self.inputs.nixos-hardware.nixosModules; [ common-pc-laptop ];

  hardware.disks.main.id = "/dev/sda";

  display.gnome.enable = true;

  topology.self.hardware.info = "walsgrave host";
}
