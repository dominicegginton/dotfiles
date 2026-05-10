{ self }:

with self.outputs.lib;

rec {
  default = final: prev: {
    background = final.callPackage ./pkgs/background.nix { };
    dynamic-music-pill = final.callPackage ./pkgs/dynamic-music-pill.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    solar-theme-switcher = final.callPackage ./pkgs/solar-theme-switcher { };
    smart-transparent-top-bar = final.callPackage ./pkgs/smart-transparent-top-bar { };
    lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
    mkGnomeBackground = final.callPackage ./pkgs/mk-gnome-background.nix { };
    my-shell = final.callPackage ./pkgs/shell { };
    my-shell-settings = final.callPackage ./pkgs/shell-settings { };
    plymouth-theme = final.callPackage ./pkgs/plymouth-theme.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
    topology = self.outputs.topology.${final.system}.config.output;
    twx = final.callPackage ./pkgs/twx.nix { };
    withSbomnix = prev.callPackage ./pkgs/with-sbomnix.nix { };
    youtube-tv = prev.callPackage ./pkgs/youtube-tv.nix { };
    lib = prev.lib.recursiveUpdate prev.lib self.outputs.lib;
    gnomeExtensions = prev.lib.recursiveUpdate prev.gnomeExtensions {
      inherit (final) dynamic-music-pill solar-theme-switcher smart-transparent-top-bar;
    };
  };
}
