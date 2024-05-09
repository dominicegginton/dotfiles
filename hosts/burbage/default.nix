{
  hostname,
  platform,
  stateVersion,
  ...
}: {
  imports = [
    inputs.srvos.nixosModules.server
    ./disks.nix
    ./boot.nix
  ];

  modules = rec {
    nixos.stateVersion = stateVersion;
    nixos.nixpkgs.hostPlatform = platform;
    nixos.role = "server";
    services.deluge.enable = true;
    services.plex.enable = true;
    services.unifi.enable = true;
    networking.enable = true;
    networking.hostname = "burbage";
    virtualisation.enable = true;
    users.dom.enable = true;
  };
}
