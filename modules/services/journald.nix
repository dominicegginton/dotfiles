{ lib, ... }:

{
  # Limit journal logs retention to 1 day and secure/limit size to prevent log bloating attacks (notashelf's guide)
  config.services.journald.extraConfig = lib.mkDefault ''
    MaxRetentionSec=1d
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    SystemMaxFiles=100
  '';
}
