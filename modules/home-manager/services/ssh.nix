{ config, lib, ... }:

let
  cfg = config.modules.services.ssh;
in

with lib;

{
  options.modules.services.ssh.extraConfig = mkOption {
    type = types.str;
    default = "";
  };

  config = {
    programs.ssh = {
      enable = true;
      extraConfig = cfg.extraConfig or '''';
    };
  };
}
