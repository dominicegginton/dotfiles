{ lib, ... }:

{
  services.timesyncd = {
    enable = lib.mkForce true;
    settings.Time.PollIntervalMaxSec = lib.mkForce 60;
  };
}
