{ lib, ... }:

{
  security.sudo.enable = lib.mkForce false;
}
