{ lib, ... }:

{
  security.run0.wheelNeedsPassword = lib.mkDefault true;
}
