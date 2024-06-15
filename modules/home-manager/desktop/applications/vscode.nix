{ pkgs
, config
, lib
, ...
}:

let
  cfg = config.modules.desktop.applications.vscode;
  jsonType = (pkgs.formats.json { }).type;
in

with lib;

{
  options.modules.desktop.applications.vscode = {
    enable = mkEnableOption "Enable Visual Studio Code";

    extensions = mkOption {
      description = "List of Visual Studio Code extensions to install";
      type = types.listOf types.package;
    };

    userSettings = mkOption {
      description = "Configuration written to Visual Studio Code's 'sttings.json'";
      type = jsonType;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;
      extensions = with pkgs.unstable.vscode-extensions; [
        bbenoist.nix
        vscodevim.vim
      ] ++ cfg.extensions;
      userSettings = cfg.userSettings;
    };

  };
}
