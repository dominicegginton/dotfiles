{ lib, ... }:

{
  security.apparmor.enable = lib.mkForce false;
}
