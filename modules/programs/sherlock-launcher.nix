{ lib, config, pkgs, ... }:

{
  options.programs.sherlock-launcher.enable = lib.mkEnableOption "Sherlock Launcher";

  config.environment = lib.mkIf config.programs.sherlock-launcher.enable {
    systemPackages = [ pkgs.sherlock-launcher ];
    etc = {
      "sherlock-launcher/config.toml".text = ''
        [default_apps]
        calendar_client = "${lib.getExe pkgs.gnome-calendar}"
        terminal = "${lib.getExe pkgs.alacritty}"
        browser = "${lib.getExe pkgs.firefox} --name firefox %U"
        [units]
        lengths = "meters"
        weights = "kg"
        volumes = "l"
        temperatures = "C"
        currency = "GBP"
        [appearance]
        width = 800
        height = 500
        gsk_renderer = "cairo"
        search_icon = true
        use_base_css = true
        status_bar = false
        opacity = 1.0
        mod_key_ascii = ["⇧", "⇧", "⌘", "⌘", "⎇", "✦", "✦", "⌘"]
        [behavior]
        animate = false
        [runtime]
        multi = false
        center = false
        photo_mode = false
        display_raw = false
        daemonize = false
        [caching]
        enable = true
        [expand]
        enable = false
        edge = "top"
        margin = 0
        [backdrop]
        enable = true
        opacity = 0.6
        edge = "top"
        [status_bar]
        enable = false
        [search_bar_icon]
        enable = false
        [files]
        fallback = "${config.environment.etc."sherlock-launcher/fallback.json".source}"
      '';
      "sherlock-launcher/fallback.json".text = ''
        [
          {
            "name": "Music Player",
            "type": "audio_sink",
            "args": {},
            "async": true,
            "priority": 1,
            "home": "OnlyHome",
            "spawn_focus": false,
            "binds": [
              {
                "bind": "Return",
                "callback": "playpause",
                "exit": false
              },
              {
                "bind": "control+l",
                "callback": "next",
                "exit": false
              },
              {
                "bind": "control+h",
                "callback": "previous",
                "exit": false
              }
            ],
            "actions": [
              {
                "name": "Skip",
                "icon": "media-seek-forward",
                "method": "inner.next",
                "exit": false
              },
              {
                "name": "Previous",
                "icon": "media-seek-backward",
                "method": "inner.previous",
                "exit": false
              }
            ]
          },
          {
            "name": "Calculator",
            "type": "calculation",
            "args": {
              "capabilities": ["calc.math", "calc.units"]
            },
            "priority": 1,
            "on_return": "copy"
          },
          {
            "name": "App Launcher",
            "alias": "app",
            "type": "app_launcher",
            "args": {},
            "priority": 3,
            "home": "Home"
          },
          {
            "name": "Kill Process",
            "alias": "kill",
            "type": "process",
            "args": {},
            "priority": 0
          },
          {
            "name": "Web Search",
            "display_name": "Google Search",
            "tag_start": "{keyword}",
            "alias": "gg",
            "type": "web_launcher",
            "args": {
              "search_engine": "google",
              "icon": "google"
            },
            "priority": 100
          }
        ]
      '';
    };
  };
}

