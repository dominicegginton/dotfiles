{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.services.onlyoffice-documentserver = {
    enable = mkEnableOption "OnlyOffice DocumentServer";

    hostname = mkOption {
      type = types.str;
      default = "localhost";
      description = "FQDN for the OnlyOffice instance.";
    };

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Port the OnlyOffice document server should listen on.";
    };

    # Example of how to add PostgreSQL support, assuming it's managed elsewhere
    # services.postgresql.enable = mkDefault true;
    # services.onlyoffice-documentserver.postgresHost = "/run/postgresql";
    # services.onlyoffice-documentserver.postgresName = "onlyoffice";
    # services.onlyoffice-documentserver.postgresUser = "onlyoffice";
    # services.onlyoffice-documentserver.postgresPasswordFile = config.sops.secrets."onlyoffice_pg_password".path;

    # Example of how to add JWT secret, assuming it's managed via sops-nix
    # services.onlyoffice-documentserver.jwtSecretFile = config.sops.secrets."onlyoffice_jwt_secret".path;

  };

  config = mkIf config.services.onlyoffice-documentserver.enable {
    services.onlyoffice = {
      enable = true;
      inherit (config.services.onlyoffice-documentserver) hostname port;
      listenAddress = "127.0.0.1"; # Bind to localhost for Tailscale proxy

      # Disable Nginx here, as oauth2-proxy will be in front
      nginx.enable = false;

      # You might need to configure these based on your setup
      # postgresHost = "...";
      # postgresName = "...";
      # postgresUser = "...";
      # postgresPasswordFile = "...";
      # rabbitmqUrl = "...";
      # jwtSecretFile = "...";
    };

    # Ensure required services are enabled
    services.nginx.enable = mkDefault true;
    services.postgresql.enable = mkDefault true; # OnlyOffice requires PostgreSQL
    services.rabbitmq.enable = mkDefault true; # OnlyOffice requires RabbitMQ

    # Add to impermanence configuration if data needs to persist
    # environment.persistence."/persist/var/lib/onlyoffice" = {
    #   directories = [
    #     "/var/lib/onlyoffice/documentserver/App_Data"
    #   ];
    # };

  };
}
