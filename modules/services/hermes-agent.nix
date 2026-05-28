{
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.services.hermes-agent.enable {
    services.hermes-agent = {
      settings.model.default = lib.mkDefault "google/gemini-2.0-flash-001";
      environmentFiles = [ config.sops.secrets."services/hermes/env".path ];
      addToSystemPackages = lib.mkDefault true;
    };
  };
}
