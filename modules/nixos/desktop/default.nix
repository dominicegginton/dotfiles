{ config, lib, ... }:

let
  cfg = config.modules.desktop;
in

with lib;

{
  imports = [ ./sway.nix ./plasma.nix ];

  options.modules.desktop = {
    enable = mkEnableOption "desktop";

    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    boot.plymouth.enable = true;
    boot.plymouth.theme = "spinner";
    fonts = {
      enableDefaultPackages = false;
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        antialias = true;
        defaultFonts.serif = [ "Source Serif" ];
        defaultFonts.sansSerif = [ "Work Sans" "Fira Sans" "FiraGO" ];
        defaultFonts.monospace = [ "FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono" ];
        defaultFonts.emoji = [ "Noto Color Emoji" ];
        hinting.autohint = false;
        hinting.enable = true;
        hinting.style = "full";
        subpixel.rgba = "rgb";
        subpixel.lcdfilter = "light";
      };
      packages = with pkgs; [
        font-manager
        (nerdfonts.override { fonts = [ "FiraCode" "SourceCodePro" "UbuntuMono" ]; })
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
    environment.systemPackages = with pkgs; [ wpa_supplicant_gui ];
  };
}
