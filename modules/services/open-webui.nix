{ config
, lib
, tailnet
, ...
}:

let
  cfg = config.services.open-webui;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services = {
      open-webui = {
        host = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault 8080;
        openFirewall = lib.mkDefault false;
        environment = {
          OLLAMA_API_BASE_URL = lib.mkDefault "http://127.0.0.1:${toString config.services.ollama.port}";
        };
      };

      # Expose Open WebUI interface over Tailscale using tsnsrv
      tsnsrv.services."open-webui" = {
        toURL = "http://127.0.0.1:${toString config.services.open-webui.port}";
        tags = [ "tag:service-open-webui" ];
      };
    };

    # Persistent storage for Open-WebUI state
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.open-webui.stateDir
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-open-webui = {
        network = tailnet;
        addresses = [ "https://open-webui.${tailnet}" ];
      };
    };
  };
}
