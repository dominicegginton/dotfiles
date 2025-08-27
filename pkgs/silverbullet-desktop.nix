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
  name = "silverbullet-desktop";
  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    icon = fetchurl {
      name = "logo.png";
      url = "https://silverbullet.md/.client/logo.png";
      hash = "sha256-grlHOILj57arVcbE0mzdxltAr7VkdZjN/8niuAq7vJc=";
      meta.license = lib.licenses.unfree;
    };
    desktopName = "Silverbullet";
    genericName = "A tool to develop, organize and structure your personal knowledge and to make it universally accessible across all your devices.";
    categories = [ "Office" "Network" "WebBrowser" ];
    startupNotify = true;
  };
  script = writeScriptBin name ''
    #!${runtimeShell}
    if [ -z "$SB_URL" ]; then
      ${lib.getExe gum} log --level error "The SB_URL environment variable is not set. Please set it to your Silverbullet instance URL."
      exit 1
    fi
    exec ${google-chrome}/bin/${google-chrome.meta.mainProgram} ${lib.escapeShellArgs commandLineArgs} \
      --app=$SB_URL \
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
    description = "Silverbullet Desktop";
    longDescription = ''
      Silverbullet is a tool to develop, organize and structure your personal knowledge and to make it universally accessible across all your devices.

      This package provides a desktop application that runs Silverbullet in a dedicated Chromium instance.
    '';
    homepage = google-chrome.meta.homepage or null;
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = google-chrome.meta.platforms or lib.platforms.all;
  };
}
