{ config, lib, ... }:

{
  # Enable systemd-run0 for non-WSL hosts
  security.run0.enable = lib.mkDefault (!config.wsl.enable);

  # Configure systemd-run0 for enhanced security
  security.run0.wheelNeedsPassword = lib.mkIf config.security.run0.enable (lib.mkDefault true);
}
