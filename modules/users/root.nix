{ self, lib, hostname, ... }:

with lib;

{
  config.users.users.root = {
    enable = lib.mkDefault true;
    description = "System administrator";
    isNormalUser = lib.mkDefault false;
    isSystemUser = lib.mkDefault true;
    hashedPassword = lib.mkDefault null;
    openssh = {
      authorizedPrincipals = [ "root@localhost" "root@${hostname}" self.outputs.lib.maintainers.dominicegginton.email ];
      authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;
    };
  };
}
