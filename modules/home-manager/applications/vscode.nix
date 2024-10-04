{ pkgs, config, lib, ... }:

with lib;

{
  options.modules.display.applications.vscode = {
    enable = mkEnableOption "Enable Visual Studio Code";
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
        github.github-vscode-theme
        github.copilot
        github.vscode-github-actions
        github.vscode-pull-request-github
        github.codespaces
        bierner.markdown-mermaid
        bierner.markdown-emoji
        bierner.markdown-checkbox
        bierner.emojisense
        bierner.docs-view
      ];
      userSettings = {
        "workbench.colorTheme" = "GitHub Dark Default";
        "workbench.startupEditor" = "none";
        "workbench.sideBar.location" = "right";
        "editor.minimap.enabled" = false;
      };
    };

  };
}
