{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./backup.nix
    ./bluetooth.nix
    ./console.nix
    ./deluge.nix
    ./distributed-builds.nix
    ./documentation.nix
    ./environment.nix
    ./fonts.nix
    ./gpg.nix
    ./home-assistant.nix
    ./home-manager.nix
    ./homepage-dashboard.nix
    ./i18n.nix
    ./immich.nix
    ./jellyfin.nix
    ./monitoring.nix
    ./networking.nix
    ./nix-settings.nix
    ./plasma.nix
    ./secrets.nix
    ./security.nix
    ./steam.nix
    ./sway.nix
    ./system.nix
    ./theme.nix
    ./unifi.nix
    ./users.nix
    ./virtualisation.nix
    ./zsh.nix
  ];
}
