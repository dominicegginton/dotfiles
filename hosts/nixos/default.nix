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
  imports =
    [
      inputs.disko.nixosModules.disko # Disko module
      inputs.sops-nix.nixosModules.sops # Sops secrets module
      (modulesPath + "/installer/scan/not-detected.nix") # Nix installer module

      ../_modules/system.nix # System configuration
      ../_modules/boot.nix # System boot configuration
      ../_modules/documentation.nix # Documentation configuration
      ../_modules/i18n.nix # Internationalization configuration
      ../_modules/nix.nix # Nix configuration
      ../_modules/nixpkgs.nix # Nixpkgs configuration
      ../_modules/sops.nix # Sops secrets configuration

      ../_modules/environment.nix # System environment
      ../_modules/networking.nix # Networking
      ../_modules/tailescale.nix # Tailscale
      ../_modules/virtualisation.nix # Virtualisation
      ../_modules/bluetooth.nix # Bluetooth

      ./modules/systemd.nix
      ./modules/security.nix

      ./${hostname}
      ./modules/firewall.nix
      ./modules/ssh.nix
      ./modules/smartmon.nix
      ./modules/console
      ./modules/users/root.nix
      ./modules/users/${username}.nix
    ]
    # Optional modules
    ++ lib.optional (desktop != null) ./modules/desktop;
}
