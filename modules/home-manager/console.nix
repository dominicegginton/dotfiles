{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux;

  cfg = config.modules.console;
in {
  config = {
    home.sessionVariables.EDITOR = "nvim";
    home.sessionVariables.SYSTEMD_EDITOR = "nvim";
    home.sessionVariables.VISUAL = "nvim";

    programs = {
      bash.enable = true;
      git.enable = true;
      info.enable = true;
      hstr.enable = true;
      gpg.enable = true;

      zsh = {
        enable = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        autocd = true;
        defaultKeymap = "viins";
        oh-my-zsh.enable = true;
        oh-my-zsh.theme = "eastwood";
      };

      tmux = {
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
          bind-key -r F run-shell "tmux neww twm -l"
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
      };

      neovim = {
        enable = true;
        package = pkgs.neovim-nightly;
        viAlias = true;
        vimAlias = true;
        extraPackages = with pkgs; [
          ripgrep # Fast search tool
          fd # Fast search tool
          fzf # Fuzzy finder
          nodejs-slim # Node.js runtime
          nodePackages.typescript
          gcc # C compiler
          rustc # Rust compiler
          cargo # Rust package manager
          zig # Zig programming language
          tree-sitter # Parser generator tool and incremental parsing library
          rnix-lsp # Nix language server
          rust-analyzer # Rust language server
          terraform-lsp # Terraform language server
          lua-language-server # Lua language server
          nodePackages.vim-language-server # Vim language server
          nodePackages.bash-language-server # Bash language server
          nodePackages.yaml-language-server # YAML language server
          nodePackages.dockerfile-language-server-nodejs # Dockerfile language server
          nodePackages.typescript-language-server # TypeScript language server
          nodePackages.vscode-langservers-extracted # VSCode language servers (HTML, CSS, JSON, etc.)
          nodePackages."@angular/cli" # Angular CLI (including language server)
          nodePackages.pyright # Python language server
          prettierd # Prettier
          eslint_d # ESLint
          stylua # Lua formatter
        ];
      };

      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-markdown-preview # Markdown preview in browser
        ];
        settings = {
          editor = "nvim";
          git_protocol = "https";
          prompt = "enabled";
        };
      };

      nix-index-database.comma.enable = true;
    };

    services.gpg-agent = mkIf isLinux {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      git # Srouce control
      git-lfs # Git large file storage
      git-sync
      gnupg # GPG tool suite for encryption and signing
      tmux # Terminal multiplexer
      twm # Tmux window manager
      jq # JSON processor
      fx # JSON processor
      nix-output-monitor # Nix output monitor
      nix-tree # Browser dependency graphs of Nix derivations
      nix-melt # Flake lock viewer
      deadnix # Scan for dead Nix code
      nix-alien # Run unpatched binaries on Nix/NixOS
      nix-init # Generate Nix packages from URLs with hash prefetching
      manix # Nix documentation searcher
      nix-du # Disk usage of Nix store
      yazi # File manager
      twx
      rebuild-home
      todo
    ];
  };
}
