{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktop;
in {
  imports = [./sway.nix];

  options.modules.desktop = {
    enable = mkEnableOption "desktop";
    printing = mkEnableOption "printing";

    environment = mkOption {
      type = types.str;
      description = "Environment configuration";
    };

    packages = mkOption {
      type = types.listOf types.package;
      description = "Packages to be installed";
    };
  };

  config = mkIf cfg.enable {
    modules.sway.enable = mkIf (cfg.environment == "sway") true;

    xdg.portal.enable = true;
    xdg.portal.xdgOpenUsePortal = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    xdg.portal.config.common.default = "*";

    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        # Nerd fonts
        # Overriden to include FiraCode, SourceCodePro, and UbuntuMono
        (nerdfonts.override {
          fonts = ["FiraCode" "SourceCodePro" "UbuntuMono"];
        })
        fira # Fira Sans font family
        fira-go # FiraGO font family
        joypixels # JoyPixels emoji font
        liberation_ttf # Liberation font family
        noto-fonts-emoji # Noto Emoji font
        source-serif # Source Serif font family
        ubuntu_font_family # Ubuntu font family
        work-sans # Work Sans font family
        jetbrains-mono # JetBrains Mono font
        ibm-plex # IBM Plex font family
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

    programs.dconf.enable = true;

    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;

    hardware.pulseaudio.enable = lib.mkForce false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    services.printing.enable = mkIf cfg.printing true;

    environment.systemPackages = with pkgs;
      [
        pipewire # low-latency audio/video router
        alsa-utils # collection of common audio utilities
        pulseaudio # sound server
        pulsemixer # terminal mixer for pulseaudio
        pavucontrol # pulseaudio volume control
      ]
      ++ cfg.packages;
  };
}
