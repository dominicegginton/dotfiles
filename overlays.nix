## overlays.nix
#
# System-wide overlays to extend nixpkgs with custom packages and library functions.
# These overlays are applied to the nixpkgs instance used by each host.
#
# Overlays allow you to add, override, or extend packages and library functions in nixpkgs for all systems in this flake.

{ self }:

## Import the custom lib for use in overlays
with self.outputs.lib;

let
  # Helper function to map withSbomnix over a set of packages
  # This is used to add SBOM and provenance utilities to all packages in a set
  wrapWithSbomnix = withSbomnix: pkgs: (builtins.mapAttrs (_: pkg: withSbomnix pkg) pkgs);
in

rec {

  # Default overlay containing custom packages, library extensions, and sbomnix passthru wrappers
  # This overlay is always applied to all systems
  default = final: prev: rec {
    # Import the withSbomnix wrapper function
    withSbomnix = prev.callPackage ./pkgs/with-sbomnix.nix { };

    # Custom packages available in all systems
    background = final.callPackage ./pkgs/background.nix { };
    dynamic-music-pill = final.callPackage ./pkgs/dynamic-music-pill.nix { };
    extract-theme = final.callPackage ./pkgs/extract-theme.nix { };
    solar-theme-switcher = final.callPackage ./pkgs/solar-theme-switcher { };
    intelli-extension = final.callPackage ./pkgs/intelli-extension { };
    lazy-desktop = prev.callPackage ./pkgs/lazy-desktop.nix { };
    mkGnomeBackground = final.callPackage ./pkgs/mk-gnome-background.nix { };
    nix-gc-dangling-links = final.callPackage ./pkgs/nix-gc-dangling-links.nix { };
    my-shell = final.callPackage ./pkgs/shell { };
    my-shell-settings = final.callPackage ./pkgs/shell-settings { };
    plymouth-theme = final.callPackage ./pkgs/plymouth-theme.nix { };
    theme = final.callPackage ./pkgs/theme.nix { };
    twx = final.callPackage ./pkgs/twx.nix { };
    youtube-tv = prev.callPackage ./pkgs/youtube-tv.nix { };

    # DriftWM — a trackpad-first infinite canvas Wayland compositor
    driftwm = self.inputs.driftwm.packages.${prev.system}.default;

    # Topology output is now a package
    topology = self.outputs.packages.${final.system}.topology;

    # Merge custom library with nixpkgs lib
    # This allows you to extend or override lib functions globally
    lib = prev.lib.recursiveUpdate prev.lib self.outputs.lib;

    # Extend GNOME extensions with custom ones
    # These are also wrapped with sbomnix utilities for SBOM/provenance
    gnomeExtensions = prev.lib.recursiveUpdate prev.gnomeExtensions {
      inherit (final)
        dynamic-music-pill
        solar-theme-switcher
        intelli-extension
        ;
    };
  };

  withSbom = final: prev: {
    # This overlay is meant to be applied on top of the default overlay to add sbomnix passthru utilities to all packages
    # It does not add any new packages, but wraps existing ones with sbomnix utilities
    # This allows you to generate SBOMs, dependency graphs, provenance, and vulnerability scans for any package in the system
    withSbom = wrapWithSbomnix (final.withSbomnix) prev;
  };

  wsl = final: prev: {
    jetbrains = final.lib.recursiveUpdate prev.jetbrains {
      sdk = final.jetbrains.sdk.overrideAttrs (oldAttrs: {
        installPhase = (oldAttrs.installPhase or "") + ''
          wrapProgram $out/bin/sdk \
            --prefix PATH : ${final.lib.makeBinPath [ final.wslpath ]}/bin:\$PATH
        '';
      });
    };
  };
}
