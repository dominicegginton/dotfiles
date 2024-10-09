{ pkgs, config, lib, ... }:

with lib;

{
  config = {
    system.stateVersion = 5;
    nix = {
      useDaemon = true;
      gc.automatic = true;
      optimise.automatic = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
        log-lines = 100;
        connect-timeout = 30;
        fallback = true;
        warn-dirty = true;
        keep-going = true;
        keep-outputs = true;
        keep-derivations = true;
        # Set auto optimise store to false on darwin
        # to avoid the issue with the store being locked
        # and causing nix to hang when trying to build
        # a derivation. This is a temporary fix until
        # the issue is resolved in nix.
        # SEE: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = false;
        min-free = 10000000000;
        max-free = 20000000000;
        trusted-users = [ "dom" "nixremote" "root" "@wheel" ];
        trusted-users = [ "root" "nixremote" "@wheel" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "dominicegginton.cachix.org-1:P8AQ3itMEVevMqAzCKiPyvJ6l1a9NVaFPAXJqb9mAaY="
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://dominicegginton.cachix.org"
        ];
      };
    };

    system.defaults = {
      NSGlobalDomain.AppleFontSmoothing = 1;
      NSGlobalDomain.NSTableViewDefaultSizeMode = 1;
      NSGlobalDomain.AppleICUForce24HourTime = true;
      # NSGlobalDomain.AppleInterfaceStyle = "Dark";
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

    environment.systemPackages = with pkgs; [ home-manager ];

  };
}
