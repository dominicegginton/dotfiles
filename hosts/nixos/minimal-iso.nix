{ inputs, modulesPath, pkgs, lib, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nixos-images.nixosModules.image-installer
  ];
  nix.settings.experimental-features = "nix-command flakes";
  programs.bash.interactiveShellInit = ''
    if [[ "$(tty)" =~ /dev/(tty1|hvc0|ttyS0)$ ]]; then
      systemctl restart systemd-vconsole-setup.service
      ${pkgs.host-status}/bin/host-status --root-password
    fi
  '';
  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [ fuse bottom ];
}
