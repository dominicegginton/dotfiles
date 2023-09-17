{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system-utils
      ../../users/dominic.egginton
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

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  security.sudo.execWheelOnly = true;
  programs.light.enable = true;

  services.upower.enable = true;
  services.printing.enable = true;
  sound.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako
      grim
      slurp
      alacritty
      foot
      dmenu
      wofi
    ];
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  programs.waybar.enable = true;
  programs.gnupg.agent.enable = true;

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    jetbrains-mono
  ];

  system.stateVersion = "23.05";
}

