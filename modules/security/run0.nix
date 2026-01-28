{ lib, ... }:

{
  security.run0.wheelNeedsPassword = lib.mkForce true;
}
