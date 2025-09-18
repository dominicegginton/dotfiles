{ lib, config, ... }:

{
  config = lib.mkIf config.programs.firefox.enable {
    programs.firefox = {
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
