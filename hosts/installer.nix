{ lib, pkgs, config, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];

  image.baseName = lib.mkDefault "${config.nixos.distroId}-installer";
  console.earlySetup = true;

  services = {
    openssh.enable = true;
    getty.autologinUser = lib.mkForce "root";
    tailscale.enable = true;
  };

  systemd.tmpfiles.rules = [ "d /var/shared 0777 root root - -" ];

  system.activationScripts.root-password = ''
    mkdir -p /var/shared
    ${pkgs.xkcdpass}/bin/xkcdpass --numwords 3 --delimiter - --count 1 > /var/shared/root-password
    echo "root:$(cat /var/shared/root-password)" | chpasswd
  '';

  environment.systemPackages = with pkgs; [
    disko
    (writeShellScriptBin "echo-root-password" ''
      cat /var/shared/root-password | ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8
    '')
  ];

  display.gnome.enable = false;
}
