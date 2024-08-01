{ config, ... }:

let
  cfg = config.modules.services;
in

{
  imports = [
    ./bluetooth.nix
    ./deluge.nix
    ./distributed-builds.nix
    ./networking.nix
    ./plex.nix
    ./syncthing.nix
    ./unifi.nix
    ./samba.nix
    ./steam.nix
    ./virtualisation.nix
  ];
}
