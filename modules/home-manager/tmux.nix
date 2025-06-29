{ pkgs, lib, ... }:

with lib;

{
  config = {
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
        set -g status-style fg=brightwhite,bg=blue
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
    home.packages = with pkgs; [ twm twx ];
    home.file.".config/twm/twm.yaml".text = ''
      search_paths:
        - "~/.dotfiles"
        - "~/dev"
        - "~/playgrounds"
    '';
  };
}
