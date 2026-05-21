{ lib, ... }:

{
  # Enable AppArmor for enhanced application isolation
  security.apparmor.enable = lib.mkForce false;
}
