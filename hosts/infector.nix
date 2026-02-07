{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

  image.baseName = lib.mkDefault "${config.nixos.distroId}-installer";

  console.earlySetup = true;

  services.openssh.enable = true;

  services.getty.autologinUser = lib.mkForce "root";

  networking.tempAddresses = "disabled";

  systemd.tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];

  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';
}
