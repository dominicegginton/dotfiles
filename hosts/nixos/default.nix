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

      ../_modules/environment.nix # System environment
      ../_modules/networking.nix # Networking configuration
      ../_modules/bluetooth.nix  # Bluetooth

      ./modules/boot.nix
      ./modules/system.nix
      ./modules/documentation.nix
      ./modules/i18n.nix

      ./modules/nix.nix
      ./modules/nixpkgs.nix
      ./modules/sops.nix


      ./modules/virtualisation.nix
      ./modules/systemd.nix
      ./modules/security.nix

      ./${hostname}
      ./modules/firewall.nix
      ./modules/ssh.nix
      ./modules/tailescale.nix
      ./modules/smartmon.nix
      ./modules/console
      ./modules/users/root.nix
      ./modules/users/${username}.nix
    ]
    # Optional modules
    ++ lib.optional (desktop != null) ./modules/desktop;
}
