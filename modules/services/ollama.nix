{
  lib,
  config,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.ollama.enable {
    # LLM AI Services
    services.ollama = {
      loadModels = [ ]; # TODO
    };

    # Tailscale Service Definition
    services.tailscale.serve = {
      enable = true;
      services."ollama".endpoints."tcp:443" = "https+insecure://127.0.0.1:${builtins.toString 8080}";
    };
  };
}
