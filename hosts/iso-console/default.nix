{
  config,
  lib,
  hostname,
  platform,
  stateVersion,
  ...
}: {
  modules.system.stateVersion = stateVersion;
  modules.system.nixpkgs.hostPlatform = platform;
  modules.system.nixpkgs.allowUnfree = false;
  modules.sops.enable = false;
  modules.networking.enable = true;
  modules.networking.hostname = hostname;
  modules.networking.ssh = true;
  modules.users.users = ["nixos"];
}
