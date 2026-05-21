{ lib, config, ... }:

{
  config = lib.mkIf config.programs.chromium.enable {
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
  };
}
