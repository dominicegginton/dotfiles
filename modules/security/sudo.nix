{ lib, ... }:

{
  # Disable sudo in favor of more secure alternatives like Polkit and systemd-run0
  security.sudo.enable = lib.mkForce false;
}
