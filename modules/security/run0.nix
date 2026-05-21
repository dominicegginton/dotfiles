{ lib, ... }:

{
  # Configure systemd-run0 for enhanced security
  security.run0.wheelNeedsPassword = lib.mkDefault true;
}
