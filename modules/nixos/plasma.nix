{ config, lib, pkgs, ... }:

{
  options.display.enable = lib.mkEnableOption "display";

  config = lib.mkIf config.display.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.printing.enable = true;
    environment.systemPackages = with pkgs; with kdePackages; [
      kgpg
      dolphin-plugins
      maliit-keyboard
      maliit-framework
      wpa_supplicant_gui
      mpv
      vlc
      waypipe
    ];
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        antialias = true;
        defaultFonts.serif = [ "Source Serif" ];
        defaultFonts.sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        defaultFonts.monospace = [ "FiraCode Nerd Font Mono" "Noto Nerd Font Mono" ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.autohint = true;
        hinting.enable = true;
        hinting.style = "full";
        subpixel.rgba = "rgb";
        subpixel.lcdfilter = "light";
      };
      packages = with pkgs; [
        font-manager
        nerd-fonts.fira-code
        nerd-fonts.noto
        fira
        fira-go
        joypixels
        liberation_ttf
        noto-fonts-emoji
        source-serif
        ubuntu_font_family
        work-sans
        jetbrains-mono
        ibm-plex
      ];
    };
  };
}
