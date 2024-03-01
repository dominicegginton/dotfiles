{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.i18n;
in {
  options.modules.i18n = {
    location = mkOption {
      type = types.str;
      default = "en_GB.utf8";
      description = "The system location.";
    };

    timezone = mkOption {
      type = types.str;
      default = "Europe/London";
      description = "The system timezone.";
    };

    keyboardLayout = mkOption {
      type = types.str;
      default = "gb";
      description = "The keyboard layout to use.";
    };
  };

  config = {
    i18n.defaultLocale = cfg.location;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.location;
      LC_IDENTIFICATION = cfg.location;
      LC_MEASUREMENT = cfg.location;
      LC_MONETARY = cfg.location;
      LC_NAME = cfg.location;
      LC_NUMERIC = cfg.location;
      LC_PAPER = cfg.location;
      LC_TELEPHONE = cfg.location;
      LC_TIME = cfg.location;
    };

    time.timeZone = cfg.timezone;
    services.xserver.layout = cfg.keyboardLayout;
  };
}
