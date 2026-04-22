{ lib, ... }:
{
  services.timesyncd = {
    enable = lib.mkForce true;
    extraConfig = lib.mkDefault ''
      PollIntervalMaxSec=60
    '';
  };
}
