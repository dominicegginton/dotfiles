{ pkgs, ... }:

{
  config = {
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
        hinting.autohint = true;
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
  };
}
