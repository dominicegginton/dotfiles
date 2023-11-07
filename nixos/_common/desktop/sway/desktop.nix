{
  config,
  pkgs,
  ...
}: {
  programs.sway = {
    enable = true;
    wrapperFeatures = {
      base = true;
      gtk = true;
    };
    extraSessionCommands = ''
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  environment.systemPackages = with pkgs; [
    wayland
    xdg-utils
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    slurp
    wl-clipboard
    bemenu
    mako
    wdisplays
    pulseaudioFull
  ];
}
