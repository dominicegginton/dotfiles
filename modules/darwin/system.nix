{ inputs
, outputs
, config
, lib
, ...
}:
with lib; let
  cfg = config.modules.system;
in
{
  options.modules.system.stateVersion = mkOption {
    type = types.str;
    default = "20.09";
  };

  options.modules.system.nixpkgs.hostPlatform = mkOption {
    type = types.str;
    default = "x86_64-darwin";
  };

  options.modules.system.nixpkgs.allowUnfree = mkOption {
    type = types.bool;
    default = false;
  };

  options.modules.system.nixpkgs.permittedInsecurePackages = mkOption {
    type = types.listOf types.str;
    default = [ ];
  };

  config = {
    nix = {
      package = pkgs.unstable.nix;
      gc.automatic = true;
      optimise.automatic = true;
      registry = mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = false;
        trusted-users = [ "root" "@wheel" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
        ];
      };
    };

    system.defaults = {
      NSGlobalDomain.AppleFontSmoothing = 1;
      NSGlobalDomain.NSTableViewDefaultSizeMode = 1;
      NSGlobalDomain.AppleICUForce24HourTime = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
      NSGlobalDomain.AppleKeyboardUIMode = 3;
      NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
      NSGlobalDomain.AppleMetricUnits = 1;
      NSGlobalDomain.ApplePressAndHoldEnabled = true;
      NSGlobalDomain.AppleScrollerPagingBehavior = true;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowAllFiles = true;
      NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
      NSGlobalDomain.AppleTemperatureUnit = "Celsius";
      NSGlobalDomain.NSWindowResizeTime = 0.0;
      NSGlobalDomain._HIHideMenuBar = false;
      NSGlobalDomain."com.apple.swipescrolldirection" = true;
      dock.enable-spring-load-actions-on-all-items = false;
      dock.appswitcher-all-displays = false;
      dock.autohide = true;
      dock.autohide-delay = 0.25;
      dock.autohide-time-modifier = 0.0;
      dock.dashboard-in-overlay = false;
      dock.expose-animation-duration = 0.0;
      dock.expose-group-by-app = true;
      dock.launchanim = false;
      dock.magnification = false;
      dock.mineffect = "scale";
      dock.minimize-to-application = false;
      dock.mouse-over-hilite-stack = true;
      dock.mru-spaces = false;
      dock.orientation = "left";
      dock.show-process-indicators = true;
      dock.showhidden = true;
      dock.static-only = true;
      dock.tilesize = 48;
      dock.wvous-bl-corner = 1;
      dock.wvous-br-corner = 1;
      dock.wvous-tl-corner = 1;
      dock.wvous-tr-corner = 1;
      loginwindow.DisableConsoleAccess = false;
      loginwindow.GuestEnabled = false;
      loginwindow.PowerOffDisabledWhileLoggedIn = true;
      loginwindow.RestartDisabled = true;
      loginwindow.RestartDisabledWhileLoggedIn = true;
      loginwindow.SHOWFULLNAME = true;
      loginwindow.ShutDownDisabled = true;
      loginwindow.ShutDownDisabledWhileLoggedIn = true;
      menuExtraClock.IsAnalog = false;
      menuExtraClock.Show24Hour = true;
      menuExtraClock.ShowDate = 1;
      menuExtraClock.ShowDayOfMonth = true;
      menuExtraClock.ShowDayOfWeek = true;
      menuExtraClock.ShowSeconds = true;
      screencapture.disable-shadow = true;
      screensaver.askForPassword = true;
      screensaver.askForPasswordDelay = 0;
      spaces.spans-displays = false;
    };

    services.nix-deamon.enable = true;
  };
}
