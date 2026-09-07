{
  self,
  config,
  lib,
  ...
}:

{
  # ACME configuration for SSL certificates
  security.acme = {
    acceptTerms = lib.mkDefault true;
    defaults.email = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.email;
  };

  # Persistent storage for ACME certificates
  environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
    "/var/lib/acme"
  ];
}
