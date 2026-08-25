{ lib, config, ... }:

{
  config = lib.mkIf config.programs.firefox.enable {
    programs.firefox = {
      policies = {
        # Performance and security basics
        AppAutoUpdate = false;
        HardwareAcceleration = true;
        CaptivePortal = false;

        # Privacy: Disable telemetry and data collection
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;

        # UI and Behavior customization
        DontCheckDefaultBrowser = true;
        DisableSetDesktopBackground = true;
        Certificates.EnterpriseRoots = true;
        MicrosoftEntraSSO = true;
        WindowsSSO = true;

        # Clean up the "New Tab" page
        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };

        # Disable onboarding and recommendations
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };

        DisableAppUpdate = true;
        OverrideFirstRunPage = "";
        PictureInPicture.Enabled = false;
        PromptForDownloadLocation = false;

        # Low-level preference overrides
        Preferences = {
          "widget.use-xdg-desktop-portal.file-picker" = 1; # Use system file picker
          "browser.tabs.loadInBackground" = true;
          "media.ffmpeg.vaapi.enabled" = true; # Enable hardware video acceleration
          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuitShortcut" = false;
        };

        PopupBlocking = {
          Default = false;
          Locked = true;
        };

        # Privacy: Disable address bar suggestions
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
      };
    };

    # Enable Geoclue2 and permit Firefox to access location information.
    services.geoclue2 = {
      enable = lib.mkDefault true;
      appConfig.firefox = {
        desktopID = "firefox.desktop";
        isAllowed = true;
      };
    };

    # AppArmor confinement profile for Firefox
    security.apparmor.policies."usr.bin.firefox" = lib.mkIf config.security.apparmor.enable {
      state = "enforce";
      profile = ''
        #include <tunables/global>

        /usr/bin/firefox {
          #include <abstractions/base>
          #include <abstractions/nameservice>
          #include <abstractions/audio>
          #include <abstractions/fonts>
          #include <abstractions/private-files-strict>
          #include <abstractions/ssl_certs>

          /usr/bin/firefox mr,
          /nix/store/** rmix,
          @{HOME}/.mozilla/ rw,
          @{HOME}/.mozilla/** rw,
          @{HOME}/Downloads/ rw,
          @{HOME}/Downloads/** rw,

          network inet stream,
          network inet6 stream,
        }
      '';
    };
  };
}
