# NixOS.
#
# Default configuration applies to all NixOS hosts.
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
  # Modules
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")

      ./modules/boot.nix
      ./modules/system.nix
      ./modules/documentation.nix
      ./modules/i18n.nix

      ./modules/nix.nix
      ./modules/nixpkgs.nix
      ./modules/sops.nix
      ./modules/networking.nix

      ./modules/virtualisation.nix
      ./modules/systemd.nix
      ./modules/security.nix
      ./modules/enviroment.nix

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
