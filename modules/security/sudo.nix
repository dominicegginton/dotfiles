{ lib, ... }:

{
  # Disable sudo to encourage the use of more secure alternatives like Polkit and systemd-run0 for privilege escalation.
  security.sudo.enable = lib.mkForce false;
}
