{ config
, lib
, pkgs
, tailnet
, ...
}:

{
  config = lib.mkIf config.services.home-assistant.enable {
    sops.secrets = lib.mkIf (lib.sopsFileForHost config != null) {
      "services/home-assistant/gcs-backup-key" = {
        sopsFile = lib.sopsFileForHost config;
      };
    };

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
        lovelaceConfig = {
          title = "Ribble Home";
          views = [
            {
              title = "Overview";
              icon = "mdi:home-outline";
              cards = [
                {
                  type = "custom:clock-weather-card";
                  entity = "weather.metoffice";
                  sun_entity = "sun.sun";
                  temperature_sensor = "sensor.processor_temperature";
                }
                {
                  type = "custom:advanced-camera-card";
                  title = "Front Door Camera";
                  cameras = [
                    {
                      camera_entity = "camera.frontdoor";
                      frigate = {
                        client_id = "frigate";
                        camera_name = "Frontdoor";
                      };
                    }
                  ];
                }
                {
                  type = "custom:mushroom-light-card";
                  entity = "light.wled";
                  name = "WLED Ambient";
                  show_brightness_control = true;
                  show_color_temp_control = true;
                }
                {
                  type = "custom:mini-media-player";
                  entity = "media_player.jellyfin";
                  name = "Jellyfin Server";
                  artwork = "cover";
                }
              ];
            }
            {
              title = "System";
              icon = "mdi:server-network";
              cards = [
                {
                  type = "custom:mini-graph-card";
                  entities = [ "sensor.processor_use" ];
                  name = "ghost-gs60 CPU Load";
                  line_color = "#3498db";
                }
                {
                  type = "custom:mini-graph-card";
                  entities = [ "sensor.memory_use_percent" ];
                  name = "RAM Usage";
                  line_color = "#e74c3c";
                }
                {
                  type = "custom:mini-graph-card";
                  entities = [ "sensor.disk_use_percent_var" ];
                  name = "Disk Usage (/var)";
                  line_color = "#2ecc71";
                }
              ];
            }
            {
              title = "Cameras";
              icon = "mdi:cctv";
              cards = [
                {
                  type = "custom:advanced-camera-card";
                  title = "Frigate NVR - Frontdoor";
                  cameras = [
                    {
                      camera_entity = "camera.frontdoor";
                      live_provider = "ha";
                      frigate = {
                        client_id = "frigate";
                        camera_name = "Frontdoor";
                      };
                    }
                  ];
                  live = {
                    preload = true;
                  };
                }
              ];
            }
          ];
        };
        config = {
          lovelace.resource_mode = "storage";
          frontend.themes = "!include_dir_merge_named themes";
          automation = "!include automations.yaml";
          script = "!include scripts.yaml";
          scene = "!include scenes.yaml";
          homeassistant = {
            name = "Ribble";
            unit_system = "metric";
            time_zone = "Europe/London";
            temperature_unit = "C";
            auth_providers = [
              { type = "homeassistant"; }
            ];
          };
          default_config = { };
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
        };
        customComponents = with pkgs.home-assistant-custom-components; [
          adaptive_lighting
          frigate
          waste_collection_schedule
        ];
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
          advanced-camera-card
          apexcharts-card
          auto-entities
          bubble-card
          card-mod
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
        toURL = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
        funnel = lib.mkDefault false;
        tags = [ "tag:service-home-assistant" ];
      };

      # Declarative Restic snapshot backup job to Google Cloud Storage (GCS)
      restic.backups.home-assistant = {
        repository = "gs:home-assistant-backup-66ea520add6c51fb:/${config.networking.hostName}/home-assistant";
        passwordFile = config.sops.secrets."services/home-assistant/gcs-backup-key".path;
        initialize = true;
        paths = [ config.services.home-assistant.configDir ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        timerConfig = {
          OnCalendar = "03:00:00";
          Persistent = true;
        };
      };
    };

    # Pass GCP Service Account credentials to Restic and set systemd ordering after Home Assistant service
    systemd.services.restic-backups-home-assistant = {
      environment.GOOGLE_APPLICATION_CREDENTIALS =
        config.sops.secrets."services/home-assistant/gcs-backup-key".path;
      after = [ "home-assistant.service" ];
      wants = [ "home-assistant.service" ];
    };

    # Persistent storage for Home Assistant configuration and data
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.home-assistant.configDir
      config.services.home-assistant.dataDir
      "/var/lib/postgresql"
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-home-assistant = {
        network = tailnet;
        addresses = [ "https://home-assistant.${tailnet}" ];
      };

      services.home-assistant = {
        name = "Home Assistant";
        details.listen.text = "127.0.0.1:${toString config.services.home-assistant.config.http.server_port}";
      };
    };
  };
}
