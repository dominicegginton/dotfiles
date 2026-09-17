{
  self,
  config,
  options,
  lib,
  hostname,
  ...
}:

{
  networking = {
    hostName = lib.mkForce hostname;
    tempAddresses = "disabled";
    networkmanager.enable = lib.mkForce false;
  };

  console.earlySetup = true;

  # Installer image naming
  image.baseName = lib.mkIf (options ? image) (lib.mkDefault "${config.nixos.distroId}-installer");

  # Enable SSH for remote access during installation
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkOverride 20 "yes";
        PasswordAuthentication = lib.mkOverride 20 true;
      };
    };
    getty.autologinUser = lib.mkForce "root";
    tailscale.enable = lib.mkForce false;
    tsnsrv.enable = lib.mkForce false;
    usbguard.enable = lib.mkForce false;
    beszel.enable = lib.mkForce false;
  };

  # Authorize maintainer SSH keys for root on the live ISO installer
  users.users.root.openssh.authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;

  # Disable non-installer user and services
  users.dom.enable = false;
  boot.plymouth.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  programs.deadman.enable = lib.mkForce false;
}
