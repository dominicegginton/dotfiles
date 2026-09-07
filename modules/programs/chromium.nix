{ lib, config, ... }:

let
  cfg = config.programs.chromium;
in

{
  config = lib.mkIf cfg.enable {
    # Chromium privacy and behavior policies
    programs.chromium = {
      extraOpts = lib.mkDefault {
        "BrowserSignin" = 0; # Disable browser sign-in
        "SyncDisabled" = true; # Disable Google sync
        "PasswordManagerEnabled" = false; # Use external password manager
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [ "en-UK" ];
      };
    };

    # Persistent storage for Chromium profile
    environment.persistence."/persist".users.dom.directories = lib.mkIf config.impermanence.enable [
      ".config/chromium"
    ];
  };
}
