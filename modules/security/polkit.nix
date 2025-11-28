{ lib, ... }:

{
  security.polkit.enable = lib.mkDefault true;
}

