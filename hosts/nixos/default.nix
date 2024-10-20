{ inputs, hostname, modulesPath, ... }:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.base16.nixosModule
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ../../modules/nixos
  ];
}
