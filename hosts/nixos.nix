{
  inputs,
  hostname,
  modulesPath,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/nixos/system.nix
    ../modules/nixos/sops.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/virtualisation.nix
    ../modules/nixos/bluetooth.nix
    ../modules/nixos/users.nix
    ../modules/nixos/console.nix
    ../modules/nixos/desktop.nix
    ./${hostname}
  ];
}
