# Localisation.
#
# Localisation system configuration.
{...}: let
  keyboardLayout = "gb";
  location = "en_GB.utf8";
  timezone = "Europe/London";
in {
  # Host system timezone.
  time.timeZone = timezone;

  # Host system location.
  i18n = {
    defaultLocale = location;
    extraLocaleSettings = {
      LC_ADDRESS = location;
      LC_IDENTIFICATION = location;
      LC_MEASUREMENT = location;
      LC_MONETARY = location;
      LC_NAME = location;
      LC_NUMERIC = location;
      LC_PAPER = location;
      LC_TELEPHONE = location;
      LC_TIME = location;
    };
  };

  # Keyboard layout.
  services.xserver.layout = keyboardLayout;
}
