{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "latitude-7390";
  networking.wireless = {
    enable = true;
    userControlled = {
      enable = true;
      group = "wheel";
    };

  };

  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  nix.gc = {
    automatic = true;
    dates = "03:15";
    options = "-d";
  };

  security.sudo.execWheelOnly = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock.text = ''
    # PAM configuration file for the swaylock screen locker. By default, it includes
    # the 'login' configuration file (see /etc/pam.d/login)
    auth include login
  '';

  nixpkgs.config.allowUnfree = true;

  services.upower.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.zsh.enable = true;
  programs.light.enable = true;

  users.users.dom = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "23.05";
}