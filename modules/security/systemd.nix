{ lib, ... }:

{
  systemd.coredump.enable = lib.mkDefault false; # Disable coredumps to prevent memory leaks and secrets exposure

  # Pedantic global systemd security defaults for all services
  systemd.settings.Manager = {
    DefaultNoNewPrivileges = "yes";
  };
}
