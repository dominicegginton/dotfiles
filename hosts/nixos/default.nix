{ inputs
, hostname
, modulesPath
, ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
    }
    inputs.base16.nixosModule
    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ../../modules/nixos
  ];
}
