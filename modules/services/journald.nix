{ lib, ... }:

{
  # Limit journal logs retention to 1 day
  config.services.journald.extraConfig = lib.mkDefault ''
    MaxRetentionSec=1d
  '';
}
