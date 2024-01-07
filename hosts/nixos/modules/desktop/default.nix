{
  desktop,
  pkgs,
  ...
}: {
  imports = [
    ./${desktop}.nix
    ../opengl.nix
    ../cups.nix
    ../pipewire.nix
  ];

  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "SourceCodePro" "UbuntuMono"];})
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

    enableDefaultPackages = false;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = ["Source Serif"];
        sansSerif = ["Work Sans" "Fira Sans" "FiraGO"];
        monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
        emoji = ["Noto Color Emoji"];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "full";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.dconf.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  environment.systemPackages = with pkgs; [
    alacritty
  ];
}
