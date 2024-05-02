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
    ./${hostname}
    ../modules/nixos
  ];
}
