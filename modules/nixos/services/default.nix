{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.services;
in {
  imports = [
    ./deluge.nix
    ./plex.nix
    ./unifi.nix
  ];
}
