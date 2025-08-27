{ fetchurl
, lib
, makeDesktopItem
, runtimeShell
, symlinkJoin
, writeScriptBin
, gum
, google-chrome
, commandLineArgs ? [ ]
}:

let
  name = "frigate-desktop";
  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    icon = fetchurl {
      name = "favicon.svg";
      url = "https://raw.githubusercontent.com/blakeblackshear/frigate/refs/heads/dev/web/images/favicon.svg";
      hash = "sha256-EmTxJ9ihpEowau40p21Y1hz0SkZG6+2KGxANB57ta40=";
      meta.license = lib.licenses.unfree;
    };
    desktopName = "Frigate";
    genericName = "Frigate is an open source NVR built around real-time AI object detection.";
    categories = [ "Utility" "Network" "WebBrowser" ];
    startupNotify = true;
  };
  script = writeScriptBin name ''
    #!${runtimeShell}
    if [ -z "$FG_URL" ]; then
      ${lib.getExe gum} log --level error "The FG_URL environment variable is not set. Please set it to your Silverbullet instance URL."
      exit 1
    fi
    exec ${google-chrome}/bin/${google-chrome.meta.mainProgram} ${lib.escapeShellArgs commandLineArgs} \
      --app=$FG_URL \
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
    description = "Frigate Desktop";
    longDescription = ''
      Frigate is an open source NVR built around real-time AI object detection.

      This package provides a desktop application that runs Frigate in a dedicated Chromium instance.
    '';
    homepage = google-chrome.meta.homepage or null;
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = google-chrome.meta.platforms or lib.platforms.all;
  };
}
