{ pkgs, config, lib, ... }:

{
  options.programs.vscode.enable = lib.mkEnableOption "VSCode";

  config = lib.mkIf config.programs.vscode.enable {
    environment.systemPackages = [ pkgs.vscode ];
  };
}

