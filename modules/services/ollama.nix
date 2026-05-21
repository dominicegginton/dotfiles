{
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.services.ollama.enable {
    # Ensure Tailscale is available for secure remote access
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    # Ollama AI service configuration
    services.ollama = {
      host = lib.mkDefault "0.0.0.0";
      port = lib.mkDefault 2824;
      openFirewall = lib.mkDefault false;
      loadModels = lib.mkDefault [ ];
    };

    # Expose Ollama via Tailscale Serve
    services.tailscale.serve = {
      enable = lib.mkDefault true;
      services."ollama".endpoints."tcp:443" =
        lib.mkDefault "https+insecure://127.0.0.1:${builtins.toString config.services.ollama.port}";
    };
  };
}
