{ lib, ... }:

{
  config.services.journald.extraConfig = ''
    MaxRetentionSec=1d
  '';
}
