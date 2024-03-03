{
  config,
  lib,
  pkgs,
}:
with lib; let
  cfg = config.modules.homemanager;
in {
  options = {
    enable = mkEnableOption "Enable Home Manager";

    username = mkOption {
      type = types.str;
      description = "The username of the user for whom to manage the home directory.";
    };
  };

  config = mkIf cfg.enable {};
  imports = mkIf cfg.enable [];
}
