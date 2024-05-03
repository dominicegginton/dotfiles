{
  hostname,
  platform,
  stateVersion,
  ...
}: {
  imports = [];

  modules = rec {
    nixos.stateVersion = stateVersion;
    nixos.nixpkgs.hostPlatform = platform;
    networking.enable = true;
    networking.hostname = "burbage";
    virtualisation.enable = true;
    users.dom.enable = true;
  };
}
