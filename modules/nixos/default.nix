{ inputs, config, lib, pkgs, modulesPath, stateVersion, theme, ... }:

with lib;

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    ./bluetooth.nix
    ./console.nix
    ./display.nix
    ./distributed-builds.nix
    ./documentation.nix
    ./environment.nix
    ./gpg.nix
    ./home-assistant.nix
    ./home-manager.nix
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
