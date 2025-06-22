{ pkgs, ... }:

{
  config = {
    home.file = {
      ".aws/config".source = ./sources/.aws/config;
      ".face".source = ./face.jpg;
      ".config".source = ./sources/.config;
      ".config".recursive = true;
      ".arup.gitconfig".source = ./sources/.arup.gitconfig;
      ".editorconfig".source = ./sources/.editorconfig;
      ".gitconfig".source = ./sources/.gitconfig;
      ".gitignore".source = ./sources/.gitignore;
      ".gitmessage".source = ./sources/.gitmessage;
      ".ideavimrc".source = ./sources/.ideavimrc;
    };

    programs.firefox.enable = true;
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          github.github-vscode-theme
          github.vscode-pull-request-github
          github.vscode-github-actions
          github.copilot
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "vscode-jest";
              publisher = "orta";
              version = "6.4.3";
              hash = "sha256-naSH6AdAlyDSW/k250cUZGYEdKCUi63CjJBlHhkWBPs=";
            };
          })
          ms-azuretools.vscode-docker
          bbenoist.nix
          sumneko.lua
          ms-python.python
          tekumara.typos-vscode
        ];
        userSettings = {
          editor.minimap.enabled = false;
          workbench.colorTheme = "Solarized Light";
          workbench.activityBar.location = "top";
          workbench.sideBar.location = "right";
          workbench.startupEditor = "none";
        };
      };
    };

    programs.zsh.shellAliases = {
      cat = "bat";
      ls = "eza";
    };
    home.packages = with pkgs; [
      nix-output-monitor
      cachix
      bat
      eza
      gitui
      unstable.teams-for-linux
      jetbrains.datagrip
      jetbrains.webstorm
      chromium
      nyxt
    ];
  };
}
