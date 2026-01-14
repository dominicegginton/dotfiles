{ lib, ... }:
{
  services.timesyncd = {
    enable = lib.mkForce true;
    extraConfig = ''
      PollIntervalMaxSec=60
    '';
  };
}
