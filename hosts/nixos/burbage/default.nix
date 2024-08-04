{ hostname
, platform
, stateVersion
}: {
  imports = [
    inputs.srvos.nixosModules.server
    ./disks.nix
    ./boot.nix
  ];

  modules = {
    nixos.stateVersion = stateVersion;
    nixos.nixpkgs.hostPlatform = platform;
    networking.enable = true;
    networking.hostname = "burbage";
    virtualisation.enable = true;
    users.dom.enable = true;
  };
}
