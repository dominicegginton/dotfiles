{ lib, ... }:

{
  # Enable Polkit for fine-grained access control to privileged operations
  security.polkit.enable = lib.mkDefault true;
}
