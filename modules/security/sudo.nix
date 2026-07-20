{ lib, config, ... }:

{
  # Disable sudo in favor of more secure alternatives like Polkit and systemd-run0, except on WSL
  security.sudo.enable = lib.mkForce config.wsl.enable;
}
