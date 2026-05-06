{ self }:

with self.outputs.lib;

rec {
  default = final: prev: {
    background = final.callPackage ./pkgs/background.nix { };
    dynamic-music-pill = final.callPackage ./pkgs/dynamic-music-pill.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    solar-theme-switcher = final.callPackage ./pkgs/solar-theme-switcher { };
    rounded-window-corners-default = final.callPackage ./pkgs/rounded-window-corners-default { };
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
      inherit (prev) dynamic-music-pill;
      inherit (final) solar-theme-switcher;
      inherit (final) rounded-window-corners-default;
    };
  };
}
