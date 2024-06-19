{ config, ... }:

let
  cfg = config.modules.services;
in

{
  imports = [
    ./bluetooth.nix
    ./deluge.nix
    ./networking.nix
    ./plex.nix
    ./unifi.nix
    ./samba.nix
    ./virtualisation.nix
  ];
}
