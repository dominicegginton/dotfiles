{ config
, lib
, pkgs
, tailnet
, ...
}:

let
  cfg = config.services.home-assistant;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
      (lib.mkSingletonAssertion "home-assistant" [
        "services"
        "home-assistant"
        "enable"
      ])
    ];

    services = {
      # Enable Mosquitto MQTT Broker for Frigate, Zigbee2MQTT, ESPHome, and HA integration
      mosquitto = {
        enable = lib.mkDefault true;
        listeners = [
          {
            acl = [ "pattern readwrite #" ];
            settings.allow_anonymous = true;
          }
        ];
      };

      # Enable PostgreSQL database server for Home Assistant recorder backend
      postgresql = {
        enable = lib.mkDefault true;
        ensureDatabases = [ "hass" ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
        ];
      };

      # Enable Matter Server daemon for local Matter/Thread device control
      matter-server.enable = lib.mkDefault true;

      # Enable Wyoming local voice daemons (Piper TTS & Faster-Whisper STT)
      wyoming = {
        piper.servers."en" = {
          enable = true;
          voice = "en_GB-alan-low";
          uri = "tcp://127.0.0.1:10200";
        };
        faster-whisper.servers."en" = {
          enable = true;
          model = "base.en";
          language = "en";
          uri = "tcp://127.0.0.1:10300";
        };
      };

      home-assistant = {
        package = pkgs.home-assistant;
        lovelaceConfigWritable = true;
        configWritable = true;
        config = {
          default_config = { };
          homeassistant = {
            name = "Ribble";
            unit_system = "metric";
            time_zone = "Europe/London";
            temperature_unit = "C";
            auth_providers = [
              { type = "homeassistant"; }
            ];
          };
          mobile_app = { };
          history = { };
          recorder = {
            db_url = "postgresql://@/hass";
            purge_keep_days = 30;
            auto_purge = true;
            exclude = {
              domains = [ "updater" ];
              entity_globs = [
                "sensor.time*"
                "sensor.date*"
                "sensor.uptime*"
              ];
            };
          };
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
          };
        };
        customComponents = with pkgs.home-assistant-custom-components; [
          adaptive_lighting
          frigate
          uix
          waste_collection_schedule
        ];
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
          advanced-camera-card
          apexcharts-card
          auto-entities
          bubble-card
          clock-weather-card
          mini-graph-card
          mini-media-player
          mushroom
        ];
        extraComponents = [
          "default_config"
          "esphome"
          "my"
          "shopping_list"
          "wled"
          "history"
          "met"
          "date"
          "datetime"
          "caldav"
          "configurator"
          "flux"
          "sun"
          "moon"
          "hue"
          "matter"
          "media_player"
          "rest_command"
          "mobile_app"
          "media_source"
          "metoffice"
          "cast"
          "rest"
          "thread"
          "threshold"
          "time"
          "time_date"
          "timer"
          "tod"
          "jellyfin"
          "transmission"
          "ollama"
          "systemmonitor"
          "uptime"
          "ping"
          "mqtt"
          "recorder"
          "wyoming"
        ];
      };

      # Expose Home Assistant securely on the Tailnet using tsnsrv
      tsnsrv.services."home-assistant" = {
        toURL = "http://127.0.0.1:8123";
        funnel = lib.mkDefault false;
        tags = [ "tag:service-home-assistant" ];
      };
    };

    # Persistent storage for Home Assistant configuration and data
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      cfg.configDir
      cfg.dataDir
      "/var/lib/postgresql"
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-home-assistant = {
        network = tailnet;
        addresses = [ "https://home-assistant.${tailnet}" ];
      };

      # TODO: Remove this override once nix-topology handles optional Home Assistant HTTP settings.
      services.home-assistant = lib.mkForce {
        name = "Home Assistant";
        icon = "services.home-assistant";
        details.listen.text = "127.0.0.1:8123";
      };

      # TODO: Remove this override once nix-topology handles null Mosquitto listener addresses.
      services.mosquitto = lib.mkIf config.services.mosquitto.enable (lib.mkForce {
        name = "Mosquitto";
        icon = "services.mosquitto";
        details = lib.listToAttrs (lib.imap0
          (i: listener: {
            name = "listen[${toString i}]";
            value.text =
              let
                address = if listener.address == null then "[::]" else listener.address;
              in
              if listener.port == 0 then address else "${address}:${toString listener.port}";
          })
          config.services.mosquitto.listeners);
      });
    };
  };
}
