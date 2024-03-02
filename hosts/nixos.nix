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
    inputs.disko.nixosModules.disko # Declarative disk partitioning
    inputs.impermanence.nixosModules.impermanence # Impermanence state management
    inputs.sops-nix.nixosModules.sops # Sops secrets encryption
    (modulesPath + "/installer/scan/not-detected.nix") # Nix installer
    ../modules/system.nix # Nix system and environment configuration
    ../modules/sops.nix # Sops secrets configuration
    ../modules/networking.nix # Networking, firewall and tailscale configuration
    ../modules/virtualisation.nix # Virtualisation
    ../modules/bluetooth.nix # Bluetooth conectivity
    ../modules/users.nix # Users configuration
    ../modules/console.nix # Console environment
    ../modules/desktop.nix # Desktop environment
    ./${hostname} # Host specific configuration
  ];

  security.sudo.extraConfig = "Defaults lecture=never";
  system.activationScripts.createPersist = "mkdir -p /nix/persist";
   environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/bluetooth"
      "/var/lib/pipewire"
    ];
    files = ["/etc/machine-id"];
  };}
