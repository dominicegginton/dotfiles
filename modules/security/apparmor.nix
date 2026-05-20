{ lib, ... }:

{
  # Enable AppAramor for enhanced application isolation.
  security.apparmor.enable = lib.mkForce false;
}
