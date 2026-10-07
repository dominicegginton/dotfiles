{ pkgs }:

let
  inherit (pkgs.lib) makeBinPath;
  lockBinPath = makeBinPath (
    with pkgs;
    [
      swaylock-effects
      maim
      imagemagick
      ffmpegthumbnailer
      xclip
    ]
  );
  screenshotBinPath = makeBinPath (
    with pkgs;
    [
      wl-clipboard
      gradia
    ]
  );
  wallpaperBinPath = makeBinPath (
    with pkgs;
    [
      glib
      swaybg
      procps
      coreutils
      gnugrep
      findutils
    ]
  );
in
{
  screen-lock = pkgs.writeShellScriptBin "screen-lock" ''
    PATH=${lockBinPath}
    TEMP_IMG=$(mktemp /tmp/screen-lock-XXXXXX.png)
    maim -u | convert - -blur 0x8 -scale 10% -scale 1000% $TEMP_IMG
    swaylock-effects -f -i $TEMP_IMG --effect-blur 10x10
    rm $TEMP_IMG
  '';

  screenshot-output = pkgs.writeShellScriptBin "screenshot-output" ''
    PATH=${screenshotBinPath}
    gradia --screenshot=FULL
  '';

  screenshot-region = pkgs.writeShellScriptBin "screenshot-region" ''
    PATH=${screenshotBinPath}
    gradia --screenshot
  '';

  sway-wallpaper = pkgs.writeShellScriptBin "sway-wallpaper" ''
    PATH=${wallpaperBinPath}

    update_wallpaper() {
      THEME=$(gsettings get org.gnome.desktop.interface color-scheme | tr -d "'")
      if [ "$THEME" = "prefer-dark" ]; then
        IMAGE=$(gsettings get org.gnome.desktop.background picture-uri-dark | tr -d "'" | sed 's/file:\/\///')
      else
        IMAGE=$(gsettings get org.gnome.desktop.background picture-uri | tr -d "'" | sed 's/file:\/\///')
      fi

      if [ -f "$IMAGE" ]; then
        pkill swaybg || true
        swaybg -i "$IMAGE" -m fill &
      fi
    }

    update_wallpaper

    gsettings monitor org.gnome.desktop.interface color-scheme | while read -r _; do update_wallpaper; done &
    gsettings monitor org.gnome.desktop.background picture-uri | while read -r _; do update_wallpaper; done &
    gsettings monitor org.gnome.desktop.background picture-uri-dark | while read -r _; do update_wallpaper; done &

    wait
  '';
}
