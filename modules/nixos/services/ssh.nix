{ config, lib, ... }:

let
  cfg = config.modules.services.ssh;
in

with lib;

{
  options.modules.services.ssh.enable = mkEnableOption "ssh";

  config = mkIf cfg.enable {
    services.openssh.enable = true;
  };
}
