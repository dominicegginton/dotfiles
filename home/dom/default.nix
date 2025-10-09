{ inputs, lib, osConfig, pkgs, ... }:

let
  gui = osConfig.display.niri.enable || osConfig.display.gnome.enable;
in

{
  imports = [
    ./git.nix
    ./tmux.nix
    ./zsh.nix
  ];
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

    home.file.".mozilla/firefox/default/chrome/firefox-gnome-theme".source = lib.mkIf osConfig.programs.firefox.enable inputs.firefox-gnome-theme;

    programs.firefox.profiles.default = lib.mkIf osConfig.programs.firefox.enable {
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';
      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
        "browser.theme.dark-private-windows" = false;
      };
    };

    # todo: move this into a nixos module
    programs.vscode = lib.mkIf osConfig.programs.vscode.enable {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
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
          editor.renderLineHighlight = "none";
          extensions.ignoreRecommendations = true;
          extensions.autoCheckUpdates = false;
          extensions.autoUpdate = false;
          terminal.integrated.defaultProfile.linux = "zsh";
          updates.mode = "none";
          window.titleBarStyle = "native";
          window.commandCenter = true;
          window.autoDetectColorScheme = true;
          workbench.activityBar.location = "top";
          workbench.sideBar.location = "right";
          workbench.startupEditor = "none";
          workbench.iconTheme = null;
          workbench.tree.indent = 12;
        };
      };
    };

    programs.zsh.shellAliases = {
      cat = "bat";
      ls = "eza";
    };
    programs.ssh.enable = true;
    programs.gpg.enable = true;
    services.gpg-agent = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };

    home.sessionVariables = {
      SB_URL = "https://sb.ghost-gs60";
      FG_URL = "http://fg.ghost-gs60";
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
    };

    programs.neovim = {
      enable = true;
      package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      extraPackages = with pkgs; [
        ripgrep
        fd
        fzf
        tree-sitter
        nixd
        gcc
        rustc
        cargo
        rust-analyzer
        nodejs
        nodePackages.typescript
        terraform-lsp
        lua-language-server
        nodePackages.vim-language-server
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        prettierd
        eslint_d
        nixpkgs-fmt
        stylua
        typos-lsp
        pyright
      ];
    };

    home.packages = with pkgs; [
      nix-output-monitor
      cachix
      bat
      eza
      gitui
      bitwarden-cli
    ] ++ lib.optionals gui [
      unstable.teams-for-linux
      chromium
      bleeding.youtube
      silverbullet-desktop
      frigate-desktop
    ];
  };
}
