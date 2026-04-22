{ lib, config, ... }:

{
  config = lib.mkIf config.programs.chromium.enable {
    programs.chromium = {
      extraOpts = lib.mkDefault {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [ "en-UK" ];
      };
    };
  };
}
