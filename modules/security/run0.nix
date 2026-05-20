{ lib, ... }:

{
  # Configure systemd-run0 for enhanced security when running processes on behalf of users.
  security.run0.wheelNeedsPassword = lib.mkDefault true;
}
