{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./backup.nix
    ./bluetooth.nix
    ./gcsfuse.nix
    ./home-assistant.nix
    ./networking.nix
    ./niri.nix
    ./secrets.nix
    ./steam.nix
    ./system.nix
    ./unifi.nix
    ./users.nix
    ./virtualisation.nix
  ];
}
