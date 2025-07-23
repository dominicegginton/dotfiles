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

    programs.firefox = {
      enable = true;
      profiles =
        let
          settings = {
            browser.urlbar.suggest.history = false;
            browser.urlbar.suggest.bookmark = false;
            browser.urlbar.suggest.openpage = false;
            browser.urlbar.suggest.searches = false;
            toolkit.legacyUserProfileCustomizations.stylesheets = true;
            layers.acceleration.force-enabled = true;
            gfx.webrender.all = true;
            svg.context-properties.content.enabled = true;
          };
        in
        {
          personal = {
            id = 0;
            isDefault = true;
            name = "Dominic Egginton";
            userChrome = ./sources/userChrome.css;
            inherit settings;
          };
          arup = {
            id = 1;
            name = "Dominic Egginton - Arup";
            userChrome = ./sources/userChrome.css;
            inherit settings;
          };
        };
    };
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
          terminal.integrated.defaultProfile.linux = "zsh";
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
      bitwarden-cli
    ];
  };
}
