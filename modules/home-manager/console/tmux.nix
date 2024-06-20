{ pkgs
, lib
, config
, username
, ...
}:

let
  cfg = config.modules.console.tmux;
  twmCfg = config.modules.console.twm;
in

with lib;

{

  options.modules.console = {
    tmux = {
      extraConfig = mkOption {
        description = "Extra configuration";
        type = types.str;
        default = "";
      };
    };

    twm.config = mkOption {
      description = "Configuration for twm";
      type = types.str;
      default = "";
    };
  };

  config = {
    programs.tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      aggressiveResize = true;
      extraConfig = cfg.extraConfig or '''';
    };

    home.packages = with pkgs; [ twm twx ];
    home.file.".config/twm/twm.yaml".text = twmCfg.config or '''';
  };
}
