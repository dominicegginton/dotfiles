{ config, inputs, modulesPath, pkgs, lib, ... }:

with lib;

{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-base.nix") ];
  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = config.system.nixos.version;
  boot.supportedFilesystems.bcachefs = mkDefault true;
  environment.systemPackages = with pkgs; [ fuse bottom ];
  boot.kernelParams = [ "nouveau.modeset=0" ];
  services.openssh.enable = mkDefault true;
  networking.firewall.enable = mkDefault false;
  networking.useNetworkd = mkDefault true;
  systemd.network.enable = mkDefault true;
  networking.firewall.allowedUDPPorts = [ 5353 ];
  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = mkDefault "yes";
  systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = mkDefault "yes";
  networking.hostName = mkDefault "nixos-installer";
  networking.wireless.enable = false;
  networking.wireless.iwd = mkDefault {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings.AutoConnect = true;
    };
  };
  programs.bash.interactiveShellInit = mkDefault ''
    export PATH=${makeBinPath [ pkgs.host-status ]}
    if [[ "$(tty)" =~ /dev/(tty1|hvc0|ttyS0)$ ]]; then
      systemctl restart systemd-vconsole-setup.service
      watch host-status
    fi
  '';
}
