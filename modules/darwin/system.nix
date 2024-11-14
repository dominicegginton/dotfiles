{ lib, config, ... }:

let
  cfg = config.modules.system;
in

with lib;

{
  options.modules.system.defaults = mkOption { type = types.attrs; defaults = { }; };

  config = {
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
  };
}
