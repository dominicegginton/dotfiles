{ lib, ... }:

{
  # Limit journal logs retention to 1 day and secure/limit size to prevent log bloating attacks (notashelf's guide)
  config.services.journald.settings.Journal = {
    MaxRetentionSec = lib.mkDefault "1d";
    SystemMaxUse = lib.mkDefault "100M";
    RuntimeMaxUse = lib.mkDefault "50M";
    SystemMaxFiles = lib.mkDefault 100;
  };
}
