{ inputs, lib, osConfig, pkgs, ... }:

let
  gui = osConfig.display.niri.enable || osConfig.display.gnome.enable;
in

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

    programs.tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      aggressiveResize = true;
      extraConfig = ''
        set -g status on
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",xterm-256color:Tc"
        set -g repeat-time 2000
        set -g mouse on
        set -g history-limit 50000
        set -g display-time 4000
        set -g status-interval 5
        set -g focus-events on
        set -g window-size latest
        set -g base-index 1
        set-window-option -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        setw -g monitor-activity on
        set -g visual-bell on
        set -g visual-activity on
        set -g status on
        set -g status-justify left
        set -g status-left-length 100
        set -g status-right-length 100
        set -g status-style fg=black,bg=blue
        set -g status-left " #S "
        set -g status-right " %d-%m %H:%M #h "
        set -g message-style fg=black,bg=red
        set -g message-command-style fg=black,bg=red
        set -g pane-border-style fg=black,bg=default
        set -g pane-active-border-style fg=blue,bg=default
        set -g window-status-style fg=default,bg=default
        set -g window-status-current-style fg=black,bg=brightwhite
        set -g window-status-activity-style fg=black,bg=yellow
        set -g window-status-separator ""
        set -g window-status-format " #I #W "
        set -g window-status-current-format " #I #W "
        set -g clock-mode-colour blue
        set -g mode-style fg=brightwhite,bg=red,bold
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind -r C-h select-window -t :-
        bind -r C-l select-window -t :+
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
        bind % split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind-key -r f run-shell "tmux neww twm"
        bind-key -r F run-shell "tmux neww twm -g"
        bind-key -r e run-shell "tmux neww twm -n shell -p $HOME"
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi V send-keys -X select-line
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };
    home.file.".config/twm/twm.yaml".text = ''
      search_paths:
        - "~/.dotfiles"
        - "~/dev"
        - "~/playgrounds"
    '';

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;
      defaultKeymap = "viins";
      oh-my-zsh.enable = true;
      oh-my-zsh.theme = "eastwood";
    };

    # home.file.".mozilla/firefox/default/chrome/firefox-gnome-theme" = lib.mkIf osConfig.programs.firefox.enable {
    #   source = inputs.firefox-gnome-theme;
    # };

    programs = {
      git.enable = true;
      gh = {
        enable = true;
        extensions = with pkgs; [ gh-markdown-preview ];
        settings = {
          editor = "nvim";
          git_protocol = "https";
          prompt = "enabled";
        };
      };
    };

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
          window.titleBarStyle = "custom";
          window.commandCenter = true;
          window.autoDetectColorScheme = true;
          workbench.activityBar.location = "top";
          workbench.sideBar.location = "right";
          workbench.startupEditor = "none";
          workbench.iconTheme = null;
          workbench.tree.indent = 12;
          github.copilot.enable = {
            "*" = true;
            plaintext = false;
            markdown = true;
            scminput = false;
          };
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
      SSH_AUTH_SOCK = "/home/dom/.bitwarden-ssh-socket/ssh_auth_sock";
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
      bat
      eza
      gitui
      bitwarden-cli
      twm
      twx
    ] ++ lib.optionals gui [
      fleet
      jetbrains.webstorm
      unstable.teams-for-linux
      chromium
      youtube
      silverbullet-desktop
      frigate-desktop
    ];
  };
}
