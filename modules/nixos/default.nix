{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./backup.nix
    ./bluetooth.nix
    ./frigate.nix
    ./home-assistant.nix
    ./mosquitto.nix
    ./networking.nix
    ./niri.nix
    ./secrets.nix
    ./silverbullet.nix
    ./steam.nix
    ./system.nix
    ./unifi.nix
    ./users.nix
    ./virtualisation.nix
  ];
}
