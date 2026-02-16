{ self }:

with self.outputs.lib;

rec {
  default = final: prev: {
    karren =
      let
        alacrittyConfig = (prev.formats.toml { }).generate "alacritty-config.toml" {
          colors = {
            primary = {
              background = "#6c71c1";
              foreground = "#FDF6E3";
            };
          };
        };
        karrenScript =
          runtimeScript:
          prev.writeShellScriptBin "karren" ''
            set -efu -o pipefail
            if [ $(${prev.toybox}/bin/pgrep -c karren) -gt 1 ]; then
              ${prev.libnotify}/bin/notify-send --urgency=critical --app "Karren" "Karren" "Another instance of is already running." "Please close all existing Karren windows before starting a new one."
              exit 1;
            fi

            ${prev.toybox}/bin/nohup sh -c "${prev.lib.getExe prev.alacritty} --title 'karren' --class 'karren' --config-file '${alacrittyConfig}' --command ${prev.lib.getExe (prev.writeShellScriptBin "karren-runtime" runtimeScript)}" > /dev/null 2>&1 &
          '';
      in
      {
        clipboard-history = karrenScript ''
          selection=$(${prev.cliphist}/bin/cliphist list | ${prev.fzf}/bin/fzf --no-sort --prompt "Select clipboard entry: ")
          if [ -z "$selection" ]; then
            exit 1;
          fi
          echo "$selection" | ${prev.cliphist}/bin/cliphist decode | ${prev.wl-clipboard}/bin/wl-copy
          ${prev.libnotify}/bin/notify-send --app "Karren" "" "Copied clipboard entry to clipboard."
          sleep 0.1
        '';
      };
    background = final.callPackage ./pkgs/background.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
    mkGnomeBackground = final.callPackage ./pkgs/mk-gnome-background.nix { };
    my-shell = final.callPackage ./pkgs/shell { };
    my-shell-settings = final.callPackage ./pkgs/shell-settings { };
    network-filters-disable = final.callPackage ./pkgs/network-filters-disable.nix { };
    network-filters-enable = final.callPackage ./pkgs/network-filters-enable.nix { };
    nix-rgithub-authentication = final.callPackage ./pkgs/nix-github-authentication.nix { };
    plymouth-theme = final.callPackage ./pkgs/plymouth-theme.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
    topology = self.outputs.topology.${final.system}.config.output;
    twx = final.callPackage ./pkgs/twx.nix { };
    youtube-tv = prev.callPackage ./pkgs/youtube-tv.nix { };
    withSbomnix = prev.callPackage ./pkgs/with-sbomnix.nix { };
    lib = prev.lib // self.outputs.lib;

    gnomeExtensions = prev.gnomeExtensions // {
      dynamic-music-pill = final.callPackage ./pkgs/dynamic-music-pill.nix { };
    };
  };
}
