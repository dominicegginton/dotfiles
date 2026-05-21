{ lib, ... }:

with lib;

{
  # Root user configuration
  config.users.users.root = {
    enable = lib.mkDefault true;
    description = "System administrator";
    isNormalUser = lib.mkDefault false;
    isSystemUser = lib.mkDefault true;
    hashedPassword = lib.mkDefault null;
  };
}
