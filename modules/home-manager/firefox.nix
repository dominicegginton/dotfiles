{ pkgs, lib, config, ... }:

{
  config = lib.mkIf config.programs.firefox.enable {
    home.sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DBUS_REMOTE = "1";
      MOZ_USE_XINPUT2 = "1";
      MOZ_USE_XINPUT2_BY_DEFAULT = "1";
    };

    programs.firefox = {
      package = pkgs.unstable.firefox;
      policies = {
        HardwareAcceleration = true;
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        DontCheckDefaultBrowser = true;
        DisableSetDesktopBackground = true;
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
        DisableAppUpdate = true;
        OverrideFirstRunPage = "";
        PictureInPicture.Enabled = false;
        PromptForDownloadLocation = false;
        Preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "browser.tabs.loadInBackground" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuitShortcut" = false;
        };
        PopupBlocking = {
          Default = false;
          Locked = true;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
      };
    };
  };
}
