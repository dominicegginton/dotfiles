{
  fetchurl,
  google-chrome,
  lib,
  makeDesktopItem,
  runtimeShell,
  symlinkJoin,
  writeScriptBin,
  commandLineArgs ? [ ],
}:

let
  name = "youtube-tv";
  url = "https://www.youtube.com/tv";

  desktopItem = makeDesktopItem {
    inherit name;
    exec = name;
    desktopName = "Youtube TV";
    genericName = "A video social media and online video sharing platform";
    categories = [
      "TV"
      "AudioVideo"
    ];
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

    "${google-chrome}/bin/${google-chrome.meta.mainProgram}" \
      ${lib.escapeShellArgs commandLineArgs} \
      --app=${url} \
      --new-window \
      --user-agent="Mozilla/5.0 (PS4; Leanback Shell) Gecko/20100101 Firefox/65.0 LeanbackShell/01.00.01.75 Sony PS4/ (PS4, , no, CH)" \
      --window-size=4096,2160 \
      --force-device-scale-factor=1 \
      --start-fullscreen \
      --no-default-browser-check \
      --no-crash-upload \
      --no-first-run \
      "$@" &

    CHROME_PID=$!
    wait $CHROME_PID
    exit $?
  '';
in

symlinkJoin {
  inherit name;
  paths = [
    script
    desktopItem
  ];
  meta = {
    description = "Open Youtube TV via Google Chrome app mode";
    longDescription = "YouTube is an American subscription streaming service operated by YouTube, a subsidiary of Google. See https://www.youtube.com/about";
    homepage = url;
    mainProgram = name;
    maintainers = [ lib.maintainers.dominicegginton ];
    platforms = google-chrome.meta.platforms;
  };
}
