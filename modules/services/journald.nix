{ lib, ... }:

{
  config.services.journald.extraConfig = lib.mkDefault ''
    MaxRetentionSec=1d
  '';
}
