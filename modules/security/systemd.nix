{ lib, ... }:

{
  systemd.coredump.enable = lib.mkDefault false; # Disable coredumps to prevent memory leaks and secrets exposure
}
