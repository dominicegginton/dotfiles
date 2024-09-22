# TODO: clean up this entrie file
#       default.nix
#       /console
#       /desktop
#       /desktop/applications
#       /services

{ config, lib, pkgs, username, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf;
in

{
  # TODO: see todo items in the file
  imports = [ ./sources ];

  config = {
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

    modules.display = {
      enable = true;
      plasma.enable = mkIf isLinux true;
      plasma.shortcuts = {
        "ActivityManager"."switch-to-activity-bad12a74-aaab-4185-ba10-ad68fedc3f10" = [ ];
        "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
        "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
        "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
        "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
        "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
        "kcm_touchpad"."Toggle Touchpad" = [ "Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku,Touchpad Toggle,Toggle Touchpad" ];
        "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
        "kmix"."decrease_volume" = "Volume Down";
        "kmix"."decrease_volume_small" = "Shift+Volume Down";
        "kmix"."increase_microphone_volume" = "Microphone Volume Up";
        "kmix"."increase_volume" = "Volume Up";
        "kmix"."increase_volume_small" = "Shift+Volume Up";
        "kmix"."mic_mute" = [ "Microphone Mute" "Meta+Volume Mute,Microphone Mute" "Meta+Volume Mute,Mute Microphone" ];
        "kmix"."mute" = "Volume Mute";
        "ksmserver"."Halt Without Confirmation" = "none,,Shut Down Without Confirmation";
        "ksmserver"."Lock Session" = [ "Meta+L" "Screensaver,Meta+L" "Screensaver,Lock Session" ];
        "ksmserver"."Log Out" = "\\, Ctrl+Alt+Del,Ctrl+Alt+Del,Log Out";
        "ksmserver"."Log Out Without Confirmation" = "none,,Log Out Without Confirmation";
        "ksmserver"."Reboot" = "none,,Reboot";
        "ksmserver"."Reboot Without Confirmation" = "none,,Reboot Without Confirmation";
        "ksmserver"."Shut Down" = "none,,Shut Down";
        "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
        "kwin"."ClearLastMouseMark" = "Meta+Shift+F12";
        "kwin"."ClearMouseMarks" = "Meta+Shift+F11";
        "kwin"."Cycle Overview" = [ ];
        "kwin"."Cycle Overview Opposite" = [ ];
        "kwin"."Decrease Opacity" = "none,,Decrease Opacity of Active Window by 5%";
        "kwin"."Edit Tiles" = "Meta+T";
        "kwin"."Expose" = "Ctrl+F9";
        "kwin"."ExposeAll" = [ "Ctrl+F10" "Launch (C),Ctrl+F10" "Launch (C),Toggle Present Windows (All desktops)" ];
        "kwin"."ExposeClass" = "Ctrl+F7";
        "kwin"."ExposeClassCurrentDesktop" = [ ];
        "kwin"."Grid View" = "Meta+G";
        "kwin"."Increase Opacity" = "none,,Increase Opacity of Active Window by 5%";
        "kwin"."Kill Window" = "Meta+Ctrl+Esc";
        "kwin"."Move Tablet to Next Output" = [ ];
        "kwin"."MoveMouseToCenter" = "Meta+F6";
        "kwin"."MoveMouseToFocus" = "Meta+F5";
        "kwin"."MoveZoomDown" = [ ];
        "kwin"."MoveZoomLeft" = [ ];
        "kwin"."MoveZoomRight" = [ ];
        "kwin"."MoveZoomUp" = [ ];
        "kwin"."Overview" = "Meta+W";
        "kwin"."Setup Window Shortcut" = "none,,Setup Window Shortcut";
        "kwin"."Show Desktop" = "Meta+D";
        "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
        "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
        "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
        "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
        "kwin"."Switch Window Down" = "Meta+Alt+Down";
        "kwin"."Switch Window Left" = "Meta+Alt+Left";
        "kwin"."Switch Window Right" = "Meta+Alt+Right";
        "kwin"."Switch Window Up" = "Meta+Alt+Up";
        "kwin"."Switch to Desktop 1" = "Ctrl+F1";
        "kwin"."Switch to Desktop 10" = "none,,Switch to Desktop 10";
        "kwin"."Switch to Desktop 11" = "none,,Switch to Desktop 11";
        "kwin"."Switch to Desktop 12" = "none,,Switch to Desktop 12";
        "kwin"."Switch to Desktop 13" = "none,,Switch to Desktop 13";
        "kwin"."Switch to Desktop 14" = "none,,Switch to Desktop 14";
        "kwin"."Switch to Desktop 15" = "none,,Switch to Desktop 15";
        "kwin"."Switch to Desktop 16" = "none,,Switch to Desktop 16";
        "kwin"."Switch to Desktop 17" = "none,,Switch to Desktop 17";
        "kwin"."Switch to Desktop 18" = "none,,Switch to Desktop 18";
        "kwin"."Switch to Desktop 19" = "none,,Switch to Desktop 19";
        "kwin"."Switch to Desktop 2" = "Ctrl+F2";
        "kwin"."Switch to Desktop 20" = "none,,Switch to Desktop 20";
        "kwin"."Switch to Desktop 3" = "Ctrl+F3";
        "kwin"."Switch to Desktop 4" = "Ctrl+F4";
        "kwin"."Switch to Desktop 5" = "none,,Switch to Desktop 5";
        "kwin"."Switch to Desktop 6" = "none,,Switch to Desktop 6";
        "kwin"."Switch to Desktop 7" = "none,,Switch to Desktop 7";
        "kwin"."Switch to Desktop 8" = "none,,Switch to Desktop 8";
        "kwin"."Switch to Desktop 9" = "none,,Switch to Desktop 9";
        "kwin"."Switch to Next Desktop" = "none,,Switch to Next Desktop";
        "kwin"."Switch to Next Screen" = "none,,Switch to Next Screen";
        "kwin"."Switch to Previous Desktop" = "none,,Switch to Previous Desktop";
        "kwin"."Switch to Previous Screen" = "none,,Switch to Previous Screen";
        "kwin"."Switch to Screen 0" = "none,,Switch to Screen 0";
        "kwin"."Switch to Screen 1" = "none,,Switch to Screen 1";
        "kwin"."Switch to Screen 2" = "none,,Switch to Screen 2";
        "kwin"."Switch to Screen 3" = "none,,Switch to Screen 3";
        "kwin"."Switch to Screen 4" = "none,,Switch to Screen 4";
        "kwin"."Switch to Screen 5" = "none,,Switch to Screen 5";
        "kwin"."Switch to Screen 6" = "none,,Switch to Screen 6";
        "kwin"."Switch to Screen 7" = "none,,Switch to Screen 7";
        "kwin"."Switch to Screen Above" = "none,,Switch to Screen Above";
        "kwin"."Switch to Screen Below" = "none,,Switch to Screen Below";
        "kwin"."Switch to Screen to the Left" = "none,,Switch to Screen to the Left";
        "kwin"."Switch to Screen to the Right" = "none,,Switch to Screen to the Right";
        "kwin"."Toggle Night Color" = [ ];
        "kwin"."Toggle Window Raise/Lower" = "none,,Toggle Window Raise/Lower";
        "kwin"."Walk Through Windows" = "Alt+Tab";
        "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
        "kwin"."Walk Through Windows Alternative" = [ ];
        "kwin"."Walk Through Windows Alternative (Reverse)" = [ ];
        "kwin"."Walk Through Windows of Current Application" = "Alt+`";
        "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
        "kwin"."Walk Through Windows of Current Application Alternative" = [ ];
        "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
        "kwin"."Window Above Other Windows" = "none,,Keep Window Above Others";
        "kwin"."Window Below Other Windows" = "none,,Keep Window Below Others";
        "kwin"."Window Close" = "Alt+F4";
        "kwin"."Window Fullscreen" = "none,,Make Window Fullscreen";
        "kwin"."Window Grow Horizontal" = "none,,Expand Window Horizontally";
        "kwin"."Window Grow Vertical" = "none,,Expand Window Vertically";
        "kwin"."Window Lower" = "none,,Lower Window";
        "kwin"."Window Maximize" = "Meta+PgUp";
        "kwin"."Window Maximize Horizontal" = "none,,Maximise Window Horizontally";
        "kwin"."Window Maximize Vertical" = "none,,Maximise Window Vertically";
        "kwin"."Window Minimize" = "Meta+PgDown";
        "kwin"."Window Move" = "none,,Move Window";
        "kwin"."Window Move Center" = "none,,Move Window to the Centre";
        "kwin"."Window No Border" = "none,,Toggle Window Titlebar and Frame";
        "kwin"."Window On All Desktops" = "none,,Keep Window on All Desktops";
        "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
        "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
        "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
        "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
        "kwin"."Window One Screen Down" = "none,,Move Window One Screen Down";
        "kwin"."Window One Screen Up" = "none,,Move Window One Screen Up";
        "kwin"."Window One Screen to the Left" = "none,,Move Window One Screen to the Left";
        "kwin"."Window One Screen to the Right" = "none,,Move Window One Screen to the Right";
        "kwin"."Window Operations Menu" = "Alt+F3";
        "kwin"."Window Pack Down" = "none,,Move Window Down";
        "kwin"."Window Pack Left" = "none,,Move Window Left";
        "kwin"."Window Pack Right" = "none,,Move Window Right";
        "kwin"."Window Pack Up" = "none,,Move Window Up";
        "kwin"."Window Quick Tile Bottom" = "Meta+Down";
        "kwin"."Window Quick Tile Bottom Left" = "none,,Quick Tile Window to the Bottom Left";
        "kwin"."Window Quick Tile Bottom Right" = "none,,Quick Tile Window to the Bottom Right";
        "kwin"."Window Quick Tile Left" = "Meta+Left";
        "kwin"."Window Quick Tile Right" = "Meta+Right";
        "kwin"."Window Quick Tile Top" = "Meta+Up";
        "kwin"."Window Quick Tile Top Left" = "none,,Quick Tile Window to the Top Left";
        "kwin"."Window Quick Tile Top Right" = "none,,Quick Tile Window to the Top Right";
        "kwin"."Window Raise" = "none,,Raise Window";
        "kwin"."Window Resize" = "none,,Resize Window";
        "kwin"."Window Shade" = "none,,Shade Window";
        "kwin"."Window Shrink Horizontal" = "none,,Shrink Window Horizontally";
        "kwin"."Window Shrink Vertical" = "none,,Shrink Window Vertically";
        "kwin"."Window to Desktop 1" = "none,,Window to Desktop 1";
        "kwin"."Window to Desktop 10" = "none,,Window to Desktop 10";
        "kwin"."Window to Desktop 11" = "none,,Window to Desktop 11";
        "kwin"."Window to Desktop 12" = "none,,Window to Desktop 12";
        "kwin"."Window to Desktop 13" = "none,,Window to Desktop 13";
        "kwin"."Window to Desktop 14" = "none,,Window to Desktop 14";
        "kwin"."Window to Desktop 15" = "none,,Window to Desktop 15";
        "kwin"."Window to Desktop 16" = "none,,Window to Desktop 16";
        "kwin"."Window to Desktop 17" = "none,,Window to Desktop 17";
        "kwin"."Window to Desktop 18" = "none,,Window to Desktop 18";
        "kwin"."Window to Desktop 19" = "none,,Window to Desktop 19";
        "kwin"."Window to Desktop 2" = "none,,Window to Desktop 2";
        "kwin"."Window to Desktop 20" = "none,,Window to Desktop 20";
        "kwin"."Window to Desktop 3" = "none,,Window to Desktop 3";
        "kwin"."Window to Desktop 4" = "none,,Window to Desktop 4";
        "kwin"."Window to Desktop 5" = "none,,Window to Desktop 5";
        "kwin"."Window to Desktop 6" = "none,,Window to Desktop 6";
        "kwin"."Window to Desktop 7" = "none,,Window to Desktop 7";
        "kwin"."Window to Desktop 8" = "none,,Window to Desktop 8";
        "kwin"."Window to Desktop 9" = "none,,Window to Desktop 9";
        "kwin"."Window to Next Desktop" = "none,,Window to Next Desktop";
        "kwin"."Window to Next Screen" = "Meta+Shift+Right";
        "kwin"."Window to Previous Desktop" = "none,,Window to Previous Desktop";
        "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
        "kwin"."Window to Screen 0" = "none,,Move Window to Screen 0";
        "kwin"."Window to Screen 1" = "none,,Move Window to Screen 1";
        "kwin"."Window to Screen 2" = "none,,Move Window to Screen 2";
        "kwin"."Window to Screen 3" = "none,,Move Window to Screen 3";
        "kwin"."Window to Screen 4" = "none,,Move Window to Screen 4";
        "kwin"."Window to Screen 5" = "none,,Move Window to Screen 5";
        "kwin"."Window to Screen 6" = "none,,Move Window to Screen 6";
        "kwin"."Window to Screen 7" = "none,,Move Window to Screen 7";
        "kwin"."view_actual_size" = "Meta+0";
        "kwin"."view_zoom_in" = [ "Meta++" "Meta+=\\, Zoom In,Meta++" "Meta+=,Zoom In" ];
        "kwin"."view_zoom_out" = "Meta+-";
        "mediacontrol"."mediavolumedown" = [ ];
        "mediacontrol"."mediavolumeup" = "none,,Media volume up";
        "mediacontrol"."nextmedia" = "Media Next";
        "mediacontrol"."pausemedia" = "Media Pause";
        "mediacontrol"."playmedia" = "none,,Play media playback";
        "mediacontrol"."playpausemedia" = "Media Play";
        "mediacontrol"."previousmedia" = "Media Previous";
        "mediacontrol"."stopmedia" = "Media Stop";
        "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
        "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
        "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
        "org_kde_powerdevil"."Hibernate" = "Hibernate";
        "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
        "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
        "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
        "org_kde_powerdevil"."PowerDown" = "Power Down";
        "org_kde_powerdevil"."PowerOff" = "Power Off";
        "org_kde_powerdevil"."Sleep" = "Sleep";
        "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
        "org_kde_powerdevil"."Turn Off Screen" = [ ];
        "org_kde_powerdevil"."powerProfile" = [ "Battery" "Meta+B,Battery" "Meta+B,Switch Power Profile" ];
        "plasmashell"."activate task manager entry 1" = "Meta+1";
        "plasmashell"."activate task manager entry 10" = "none,Meta+0,Activate Task Manager Entry 10";
        "plasmashell"."activate task manager entry 2" = "Meta+2";
        "plasmashell"."activate task manager entry 3" = "Meta+3";
        "plasmashell"."activate task manager entry 4" = "Meta+4";
        "plasmashell"."activate task manager entry 5" = "Meta+5";
        "plasmashell"."activate task manager entry 6" = "Meta+6";
        "plasmashell"."activate task manager entry 7" = "Meta+7";
        "plasmashell"."activate task manager entry 8" = "Meta+8";
        "plasmashell"."activate task manager entry 9" = "Meta+9";
        "plasmashell"."clear-history" = "none,,Clear Clipboard History";
        "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
        "plasmashell"."cycle-panels" = "Meta+Alt+P";
        "plasmashell"."cycleNextAction" = "none,,Next History Item";
        "plasmashell"."cyclePrevAction" = "none,,Previous History Item";
        "plasmashell"."manage activities" = "Meta+Q";
        "plasmashell"."next activity" = [ ];
        "plasmashell"."previous activity" = [ ];
        "plasmashell"."repeat_action" = "\\, Meta+Ctrl+R,Meta+Ctrl+R,Manually Invoke Action on Current Clipboard";
        "plasmashell"."show dashboard" = "Ctrl+F12";
        "plasmashell"."show-barcode" = "none,,Show Barcode…";
        "plasmashell"."show-on-mouse-pos" = "Meta+V";
        "plasmashell"."stop current activity" = "Meta+S";
        "plasmashell"."switch to next activity" = "none,,Switch to Next Activity";
        "plasmashell"."switch to previous activity" = "none,,Switch to Previous Activity";
        "plasmashell"."toggle do not disturb" = "none,,Toggle do not disturb";
        "services/org.kde.spectacle.desktop"."OpenWithoutScreenshot" = "Meta+$";
        "services/org.kde.spectacle.desktop"."RecordWindow" = [ ];
      };
      plasma.configFile = {
        "baloofilerc"."General"."dbVersion" = 2;
        "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
        "baloofilerc"."General"."exclude filters version" = 9;
        "baloofilerc"."General"."only basic indexing" = true;
        "dolphinrc"."CompactMode"."PreviewSize" = 16;
        "dolphinrc"."ContentDisplay"."UsePermissionsFormat" = "CombinedFormat";
        "dolphinrc"."DetailsMode"."PreviewSize" = 16;
        "dolphinrc"."General"."BrowseThroughArchives" = true;
        "dolphinrc"."General"."EditableUrl" = true;
        "dolphinrc"."General"."RememberOpenedTabs" = false;
        "dolphinrc"."General"."ShowFullPath" = true;
        "dolphinrc"."General"."ShowFullPathInTitlebar" = true;
        "dolphinrc"."General"."ViewPropsTimestamp" = "2024,8,4,12,48,40.991";
        "dolphinrc"."IconsMode"."IconSize" = 16;
        "dolphinrc"."IconsMode"."MaximumTextLines" = 1;
        "dolphinrc"."IconsMode"."PreviewSize" = 16;
        "dolphinrc"."IconsMode"."TextWidthIndex" = 0;
        "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
        "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
        "dolphinrc"."PreviewSettings"."Plugins" = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
        "kactivitymanagerdrc"."Plugins"."org.kde.ActivityManager.ResourceScoringEnabled" = false;
        "kactivitymanagerdrc"."activities"."bad12a74-aaab-4185-ba10-ad68fedc3f10" = "Default";
        "kactivitymanagerdrc"."main"."currentActivity" = "bad12a74-aaab-4185-ba10-ad68fedc3f10";
        "kded5rc"."Module-appmenu"."autoload" = true;
        "kded5rc"."Module-baloosearchmodule"."autoload" = true;
        "kded5rc"."Module-bluedevil"."autoload" = true;
        "kded5rc"."Module-browserintegrationreminder"."autoload" = true;
        "kded5rc"."Module-colorcorrectlocationupdater"."autoload" = true;
        "kded5rc"."Module-device_automounter"."autoload" = false;
        "kded5rc"."Module-devicenotifications"."autoload" = true;
        "kded5rc"."Module-freespacenotifier"."autoload" = true;
        "kded5rc"."Module-gtkconfig"."autoload" = true;
        "kded5rc"."Module-inotify"."autoload" = true;
        "kded5rc"."Module-kded_touchpad"."autoload" = true;
        "kded5rc"."Module-keyboard"."autoload" = true;
        "kded5rc"."Module-kscreen"."autoload" = true;
        "kded5rc"."Module-ktimezoned"."autoload" = true;
        "kded5rc"."Module-mprisservice"."autoload" = true;
        "kded5rc"."Module-plasma-session-shortcuts"."autoload" = true;
        "kded5rc"."Module-plasma_accentcolor_service"."autoload" = true;
        "kded5rc"."Module-printmanager"."autoload" = true;
        "kded5rc"."Module-remotenotifier"."autoload" = true;
        "kded5rc"."Module-smbwatcher"."autoload" = true;
        "kded5rc"."Module-statusnotifierwatcher"."autoload" = true;
        "kdeglobals"."General"."AccentColor" = "72,153,144";
        "kdeglobals"."General"."LastUsedCustomAccentColor" = "61,174,233";
        "kdeglobals"."General"."accentColorFromWallpaper" = true;
        "kdeglobals"."KDE"."AnimationDurationFactor" = 0.125;
        "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
        "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
        "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
        "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
        "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
        "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
        "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
        "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
        "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
        "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
        "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
        "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
        "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
        "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
        "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
        "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
        "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 140;
        "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
        "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 0;
        "kdeglobals"."WM"."activeBackground" = "227,229,231";
        "kdeglobals"."WM"."activeBlend" = "227,229,231";
        "kdeglobals"."WM"."activeForeground" = "35,38,41";
        "kdeglobals"."WM"."inactiveBackground" = "239,240,241";
        "kdeglobals"."WM"."inactiveBlend" = "239,240,241";
        "kdeglobals"."WM"."inactiveForeground" = "112,125,138";
        "kiorc"."Confirmations"."ConfirmDelete" = true;
        "kiorc"."Confirmations"."ConfirmEmptyTrash" = true;
        "kiorc"."Confirmations"."ConfirmTrash" = true;
        "kiorc"."Executable scripts"."behaviourOnLaunch" = "alwaysAsk";
        "krunnerrc"."Plugins"."baloosearchEnabled" = true;
        "kscreenlockerrc"."Daemon"."LockGrace" = 0;
        "kscreenlockerrc"."Greeter"."WallpaperPlugin" = "org.kde.potd";
        "kscreenlockerrc"."Greeter/Wallpaper/org.kde.potd/General"."Color" = "23,199,142";
        "kscreenlockerrc"."Greeter/Wallpaper/org.kde.potd/General"."Provider" = "simonstalenhag";
        "kwalletrc"."Auto Allow"."kdewallet" = "KDE System,discord,Chromium";
        "kwalletrc"."Wallet"."Close When Idle" = false;
        "kwalletrc"."Wallet"."Close on Screensaver" = false;
        "kwalletrc"."Wallet"."Default Wallet" = "kdewallet";
        "kwalletrc"."Wallet"."Enabled" = true;
        "kwalletrc"."Wallet"."First Use" = false;
        "kwalletrc"."Wallet"."Idle Timeout" = 10;
        "kwalletrc"."Wallet"."Launch Manager" = false;
        "kwalletrc"."Wallet"."Leave Manager Open" = false;
        "kwalletrc"."Wallet"."Leave Open" = true;
        "kwalletrc"."Wallet"."Prompt on Open" = true;
        "kwalletrc"."Wallet"."Use One Wallet" = true;
        "kwalletrc"."org.freedesktop.secrets"."apiEnabled" = true;
        "kwinrc"."Desktops"."Id_1" = "d574fc7b-cc5a-4428-a47b-515dceb3bb12";
        "kwinrc"."Desktops"."Id_2" = "42d13a19-2697-45f9-afe6-7ea1df914fc8";
        "kwinrc"."Desktops"."Number" = 2;
        "kwinrc"."Desktops"."Rows" = 1;
        "kwinrc"."Effect-diminactive"."DimDesktop" = true;
        "kwinrc"."Effect-diminactive"."DimPanels" = true;
        "kwinrc"."Effect-diminactive"."Strength" = 10;
        "kwinrc"."Input"."TabletMode" = "off";
        "kwinrc"."Plugins"."blurEnabled" = false;
        "kwinrc"."Plugins"."contrastEnabled" = true;
        "kwinrc"."Plugins"."fadeEnabled" = true;
        "kwinrc"."Plugins"."mousemarkEnabled" = true;
        "kwinrc"."Plugins"."scaleEnabled" = false;
        "kwinrc"."Plugins"."sheetEnabled" = true;
        "kwinrc"."Plugins"."zoomEnabled" = false;
        "kwinrc"."Script-desktopchangeosd"."TextOnly" = true;
        "kwinrc"."TabBox"."LayoutName" = "compact";
        "kwinrc"."TabBoxAlternative"."LayoutName" = "compact";
        "kwinrc"."Tiling"."padding" = 4;
        "kwinrc"."Tiling/0951b904-e2fe-5198-84bd-28136a2cb026"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/35723cc4-abaf-5b3e-be17-58dd53a366e7"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/3dfb7ac2-2e48-526c-9c30-b182f8536587"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/401e466e-478c-520c-b68c-97110699631b"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/5e1db788-a003-5b74-af3e-f03ec3faf9a4"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/7f91c15c-2797-5e90-bb7c-5f5117ecbde5"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/92a34333-8fd8-58d0-b644-c0d9624d9a3b"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/d57bda1d-13b9-5c5f-8352-4330803037d7"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/d6672efc-6676-5b1e-ac49-e7ec56f6247d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Tiling/e18c833d-fa66-5919-9c0d-4dcd37b1a98d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
        "kwinrc"."Wayland"."EnablePrimarySelection" = false;
        "kwinrc"."Windows"."SeparateScreenFocus" = true;
        "kwinrc"."Windows"."TitlebarDoubleClickCommand" = "Nothing";
        "kwinrc"."Xwayland"."Scale" = 1;
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "MSLFN";
        "kwinrc"."org.kde.kdecoration2"."ShowToolTips" = false;
        "plasma-localerc"."Formats"."LANG" = "en_GB.UTF-8";
        "plasmanotifyrc"."Applications/discord"."Seen" = true;
        "plasmanotifyrc"."Applications/org.telegram.desktop"."Seen" = true;
        "plasmanotifyrc"."Applications/teams-for-linux"."Seen" = true;
      };



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
                  family = "monospace";
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
              with config.scheme.withHashtag;

              let
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
      };
    };

    systemd.user.tmpfiles.rules = mkIf isLinux [
      "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    ];

    home.packages =
      with pkgs;
      [ bitwarden-cli discord ]
      ++ (if isLinux then [ whatsapp-for-linux telegram-desktop thunderbird unstable.teams-for-linux unstable.chromium unstable.zed-editor unstable.gh-copilot ]
      else [ ])
      ++ (if isDarwin then [ ]
      else [ ]);
  };
}
