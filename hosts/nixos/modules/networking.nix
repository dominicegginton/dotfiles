# Networking.
#
# Configures networking for host system.
{
  hostname,
  lib,
  ...
}: {
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
  };
}
