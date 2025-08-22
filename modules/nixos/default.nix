{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./backup.nix
    ./bluetooth.nix
    ./calmav.nix
    ./environment.nix
    ./filesystem.nix
    ./frigate.nix
    ./gnome.nix
    ./home-assistant.nix
    ./mosquitto.nix
    ./networking.nix
    ./residence.nix
    ./role.nix
    ./secrets.nix
    ./silverbullet.nix
    ./steam.nix
    ./system.nix
    ./unifi.nix
    ./users.nix
    ./virtualisation.nix
    ./wio.nix
    ./zabbix.nix
  ];
}
