# TODO: clean up this entrie file
#       default.nix
#       /console
#       /desktop
#       /desktop/applications
#       /services

{ config
, lib
, pkgs
, username
, desktop
, ...
}:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf;
in

{
  # TODO: see todo items in the file
  imports = [ ./sources ];

  config = {
    modules.theme = "light";
    modules.services = {
      ssh.extraConfig = ''
        Host i-* mi-*
          User ec2-user
          ProxyCommand sh -c "${pkgs.awscli}/bin/aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
      '';

      syncthing.enable = mkIf isLinux true;
    };

    modules.console = {
      tmux.extraConfig = ''
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
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        bind-key -n C-space if-shell -F '#{==:#{session_name},popup}' { detach-client } { if-shell -F '#{==:#{session_name},scratchpad}' { detach-client } { display-popup -d "#{pane_current_path}" -xC -yC -w 80% -h 75% -E 'tmux attach-session -t popup || tmux new-session -s popup\; set status off' } }
      '';
      twm.config = ''
        search_paths:
          - "~/.dotfiles"
          - "~/dev"
          - "~/playgrounds"
      '';

      neovim.extraPackages = with pkgs; [
        ripgrep
        fd
        fzf
        tree-sitter
        nil
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
        nodePackages.pyright
        prettierd
        eslint_d
        stylua
      ];
    };

    modules.desktop = {
      enable = true;
      plasma.enable = mkIf isLinux true;

      # TODO: provide unique config per host
      kanshi.config = ''
        profile latitude-7390 {
          output "AU Optronics 0x462D" enable mode 1920x1080 scale 1 position 0,0
        }

        profile latitude-7390-docked {
          output "AU Optronics 0x462D" disable
          output "Dell Inc. DELL 2520D 6LD5923" enable mode 2560x1440 position 0,0
          output "Dell Inc. DELL 2520D DGD5923" enable mode 2560x1440 position 2560,0
        }
      '';

      applications = {
        firefox = mkIf isLinux {
          enable = true;
          package = pkgs.firefox-devedition-bin;
        };

        alacritty = {
          enable = true;
          settings = {
            window.dynamic_padding = false;
            window.padding = {
              x = 0;
              y = 0;
            };
            scrolling.history = 10000;
            scrolling.multiplier = 3;
            selection.save_to_clipboard = true;
            font =
              let
                style = style: {
                  family = "JetBrains Mono";
                  style = style;
                };
              in
              {
                normal = style "Regular";
                bold = style "Bold";
                italic = style "Italic";
                bold_italic = style "Bold Italic";
                size = 11;
              };
            colors =
              with config.scheme.withHashtag; let
                default = {
                  black = base00;
                  white = base07;
                  inherit red green yellow blue cyan magenta;
                };
              in
              {
                primary = { background = base00; foreground = base07; };
                cursor = { text = base02; cursor = base07; };
                normal = default;
                bright = default;
                dim = default;
              };
          };
        };

        vscode = {
          enable = true;
          extensions = with pkgs.unstable.vscode-extensions; [
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

        zed-editor.enable = true;
      };
    };

    systemd.user.tmpfiles.rules = mkIf isLinux [
      "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    ];

    home.packages = with pkgs; [
      bitwarden-cli
      discord
      nodePackages_latest.webtorrent-cli
      archi
    ] ++ (if isLinux then [
      whatsapp-for-linux
      telegram-desktop
      thunderbird
      unstable.teams-for-linux
      unstable.chromium
    ] else [ ]) ++ (if isDarwin then [ ] else [ ]);
  };

}
