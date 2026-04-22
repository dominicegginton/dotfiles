{
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.services.ollama.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.ollama = {
      host = lib.mkDefault "0.0.0.0";
      port = lib.mkDefault 2824;
      openFirewall = lib.mkDefault false;
      loadModels = lib.mkDefault [ ]; # TODO
    };

    services.tailscale.serve = {
      enable = lib.mkDefault true;
      services."ollama".endpoints."tcp:443" =
        lib.mkDefault "https+insecure://127.0.0.1:${builtins.toString config.services.ollama.port}";
    };
  };
}
