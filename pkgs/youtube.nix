{ fetchurl
, stdenv
, writeText
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
  url = "https://www.youtube.com/tv";

  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    desktopName = "Youtube via Google Chrome";
    genericName = "A video social media and online video sharing platform";
    categories = [ "TV" "AudioVideo" ];
    startupNotify = true;
    icon = fetchurl {
      name = "YouTube_full_color_icon_2017.svg";
      url = "https://upload.wikimedia.org/wikipedia/commons/0/09/YouTube_full-color_icon_%282017%29.svg";
      sha256 = "sha256-fROAuewbDLM/ZhsgM9E77KfETCxAiabRTElVX/4/Ir8=";
      meta.license = lib.licenses.unfree;
    };
  };

  script = writeScriptBin name ''
    #!${runtimeShell}

    # launch chrome with the unpacked extension and wait, then cleanup
    "${google-chrome}/bin/${google-chrome.meta.mainProgram}" \
      ${lib.escapeShellArgs commandLineArgs} \
      --app=${url} \
      --new-window \
      --user-agent="Mozilla/5.0 (Linux; Android 16; BRAVIA 4K GB) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36" \
      --window-size=4096,2160 \
      --force-device-scale-factor=1 \
      --start-fullscreen \
      -force-dev-mode-highlighting
      --no-default-browser-check \
      --no-crash-upload \
      --no-first-run \
      -force-dev-mode-highlighting \
      "$@" &

    CHROME_PID=$!
    wait $CHROME_PID
    exit $?
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
    homepage = url;
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = google-chrome.meta.platforms or lib.platforms.all;
  };
}
