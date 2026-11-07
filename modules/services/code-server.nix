{ config
, lib
, pkgs
, tailnet
, ...
}:

let
  cfg = config.services.code-server;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
      (lib.mkSingletonAssertion "code-server" [
        "services"
        "code-server"
        "enable"
      ])
    ];

    services = {
      code-server = {
        host = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault 4444;
        auth = lib.mkDefault "none";
        user = lib.mkDefault "dom";
        group = lib.mkDefault "users";
        userDataDir = lib.mkDefault "${config.users.users.${cfg.user}.home}/.local/share/code-server";
        disableUpdateCheck = lib.mkDefault true;
        disableTelemetry = lib.mkDefault true;
        disableWorkspaceTrust = lib.mkDefault true;
        disableGettingStartedOverride = lib.mkDefault true;
        extraPackages = with pkgs; [
          git
          nix
          ripgrep
          fd
          fzf
          gcc
          nodejs
        ];
        extraEnvironment = lib.mkDefault {
          OLLAMA_HOST = "https://ollama.${tailnet}";
        };
      };

      # Expose code-server securely on the Tailnet using tsnsrv
      tsnsrv.services."code-server" = {
        toURL = "http://127.0.0.1:${toString config.services.code-server.port}";
        tags = [ "tag:service-code-server" ];
      };
    };

    # Persistent storage for code-server state if impermanence is enabled
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/code-server"
    ];

    # Network topology visualizer metadata
    topology.self = {
      interfaces.tsnsrv-code-server = {
        network = tailnet;
        addresses = [ "https://code-server.${tailnet}" ];
      };

      services.code-server = {
        name = "VS Code Server";
        details.listen.text =
          config.services.code-server.host + ":" + toString config.services.code-server.port;
      };
    };
  };
}
