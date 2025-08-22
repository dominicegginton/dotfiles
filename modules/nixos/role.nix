{ config, lib, ... }:

let
  role = lib.types.enum [ "server" "workstation" "kiosk" "bigscreen" "installer" ];
in

{
  options.roles = lib.mkOption {
    type = lib.types.listOf role;
    description = ''
      Define the role(s) of this machine. This is used to set various
      configuration options based on the intended use of the machine.

      Available roles:
      - server 
      - workstation
      - kiosk
      - bigscreen
      - installer

      You can specify multiple roles if the machine serves multiple purposes.
    '';
  };
  config = {
    topology.self.deviceType = lib.mkDefault "Residence ${lib.concatStringsSep ", " config.roles}";
  };
}
