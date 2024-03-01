{
  inputs,
  outputs,
  hostname,
  username,
  desktop,
  platform,
  stateVersion,
  modulesPath,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko # Disko
    inputs.sops-nix.nixosModules.sops # Sops secrets
    (modulesPath + "/installer/scan/not-detected.nix") # Nix installer
    ../_modules/system.nix # Nix system and environment configuration
    ../_modules/sops.nix # Sops secrets configuration
    ../_modules/networking.nix # Networking, firewall and tailscale configuration
    ../_modules/virtualisation.nix # Virtualisation
    ../_modules/bluetooth.nix # Bluetooth conectivity
    ../_modules/users.nix # Users configuration
    ../_modules/console.nix # Console environment
    ../_modules/desktop.nix # Desktop environment
    ./${hostname} # Host specific configuration
  ];
}
