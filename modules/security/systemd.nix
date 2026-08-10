{ config, lib, ... }:

{
  # System-wide coredump disabling to prevent memory leaks/secrets exposure
  systemd.coredump.enable = lib.mkDefault false;
}
