{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./audio.nix
    ./backup.nix
    ./bluetooth.nix
    ./console.nix
    ./documentation.nix
    ./environment.nix
    ./fonts.nix
    ./gcsfuse.nix
    ./gpg.nix
    ./home-assistant.nix
    ./home-manager.nix
    ./homepage-dashboard.nix
    ./i18n.nix
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
