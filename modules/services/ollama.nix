{ config
, lib
, tailnet
, ...
}:

let
  cfg = config.services.ollama;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Configure Ollama environment variables to allow CORS and external host headers over Tailnet
    services.ollama.environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };

    # Expose Ollama backend securely over Tailscale using tsnsrv
    services.tsnsrv.services."ollama" = {
      toURL = "http://127.0.0.1:${toString config.services.ollama.port}";
      tags = [ "tag:service-ollama" ];
    };

    # Persistent storage for Ollama data and models
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/ollama"
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-ollama = {
        network = tailnet;
        addresses = [ "https://ollama.${tailnet}" ];
      };
    };
  };
}
