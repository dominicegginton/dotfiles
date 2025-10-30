{ lib, config, ... }:

{
  config = lib.mkIf config.programs.chromium.enable {
    programs.chromium = {
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [ "en-UK" ];
      };
    };
  };
}

