{ fetchurl
, google-chrome
, wayland-utils
, wlr-randr
, lib
, makeDesktopItem
, runtimeShell
, symlinkJoin
, writeScriptBin
, commandLineArgs ? [ ]
}:

let
  name = "youtube-via-google-chrome";
  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    icon = fetchurl {
      name = "YouTube_full_color_icon_2017.svg";
      url = "https://upload.wikimedia.org/wikipedia/commons/0/09/YouTube_full-color_icon_%282017%29.svg";
      sha256 = "sha256-fROAuewbDLM/ZhsgM9E77KfETCxAiabRTElVX/4/Ir8=";
      meta.license = lib.licenses.unfree;
    };
    desktopName = "Youtube via Google Chrome";
    genericName = "A video social media and online video sharing platform";
    categories = [ "TV" "AudioVideo" ];
    startupNotify = true;
  };
  script = writeScriptBin name ''
    #!${runtimeShell}

    if command -v ${wlr-randr}/bin/wlr-randr >/dev/null; then
      screen_size=$(${wlr-randr}/bin/wlr-randr | awk '/current mode/ {print $3 "x" $4; exit}')
    elif command -v ${wayland-utils}/bin/wayland-info >/dev/null; then
      screen_size=$(${wayland-utils}/bin/wayland-info | awk '/current_mode/ {print $2 "x" $3; exit}')
    else
      screen_size="1920x1080"
    fi

    width=$screen_size%x*
    height=$screen_size%y*

    exec ${google-chrome}/bin/${google-chrome.meta.mainProgram} \
      ${lib.escapeShellArgs commandLineArgs} \
      --app=https://youtube.com/tv \
      --user-agent="Mozilla/5.0 (Linux; Android 9; BRAVIA 4K GB) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" \
      --window-size=$width,$height \
      --force-device-scale-factor=1 \
      --touch-events=enabled \
      --start-fullscreen \
      --no-first-run \
      --no-default-browser-check \
      --no-crash-upload \
      "$@"
  '';
in

symlinkJoin {
  inherit name;
  paths = [ script desktopItem ];
  meta = {
    description = "Open Youtube in Google Chrome app mode";
    longDescription = ''
      YouTube is an American social media and online video sharing platform owned by Google. See https://www.youtube.com.

      This package installs an application launcher item that opens YouTube in a dedicated Google Chrome window. If your preferred browser doesn't support YouTube's DRM, this package provides a quick and easy way to launch YouTube on a supported browser, without polluting your application list with a redundant, single-purpose browser.
    '';
    homepage = google-chrome.meta.homepage or null;
    license = google-chrome.meta.license;
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = google-chrome.meta.platforms or lib.platforms.all;
  };
}
