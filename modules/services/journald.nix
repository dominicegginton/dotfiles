{ lib, ... }:

{
  config.services.journald.extraConfig = lib.mkDefault ''
    # Limit journal logs retention to 1 day
    MaxRetentionSec=1d
  '';
}
