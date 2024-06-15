{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.modules.services.ssh;
in

with lib;

{
  options.modules.services.ssh = {
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration to be appended to the SSH configuration file";
    };
  };

  config = {
    programs.ssh = {
      enable = true;
      extraConfig = cfg.extraConfig or '''';
    };
  };
}
