{
  self,
  lib,
  ...
}:

{
  # ACME configuration for SSL certificates
  security.acme = {
    acceptTerms = lib.mkDefault true;
    defaults.email = lib.mkDefault self.outputs.lib.maintainers.dominicegginton.email;
  };
}
