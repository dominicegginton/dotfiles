{
  config,
  lib,
  platform,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "${platform}";

  modules.sops.enable = false;
}
