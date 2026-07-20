{ config, lib, ... }:

{
  # Configure systemd-run0 for enhanced security
  security.run0.wheelNeedsPassword = lib.mkIf config.security.run0.enable (lib.mkDefault true);
}
