{
  self,
  lib,
  ...
}:

{
  console.earlySetup = true;

  # Enable SSH for remote access during installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkOverride 20 "yes";
      PasswordAuthentication = lib.mkOverride 20 true;
    };
  };

  # Authorize maintainer SSH keys for root on the live ISO installer
  users.users.root.openssh.authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;

  # Auto-login as root for ease of use
  services.getty.autologinUser = lib.mkForce "root";

  networking.tempAddresses = "disabled";

  boot.plymouth.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;
  programs.deadman.enable = lib.mkForce false;
  services.tailscale.enable = lib.mkForce false;
  services.tsnsrv.enable = lib.mkForce false;
  services.usbguard.enable = lib.mkForce false;
  services.beszel.enable = lib.mkForce false;
}
