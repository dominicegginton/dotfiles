{
  config,
  lib,
  pkgs,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.garage.enable {
    # Ensure Tailscale is available for secure access via tsnsrv
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailscale.enable must be set to true";
      }
    ];

    services.garage = {
      package = pkgs.garage;
      environmentFile = config.sops.secrets."services/garage/rpc-secret".path;
      settings = {
        rpc_bind_addr = "127.0.0.1:3901";
        rpc_public_addr = "127.0.0.1:3901";

        s3_api = {
          s3_region = "garage";
          api_bind_addr = "127.0.0.1:3900";
        };
      };
    };

    # Run Garage as a system user instead of dynamic systemd user for cleaner integration with impermanence
    users.users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.groups.garage = { };

    systemd.services.garage.serviceConfig = {
      DynamicUser = false;
      User = "garage";
      Group = "garage";
    };

    # Persistent storage for Garage metadata and data
    environment.persistence."/persist".directories = [
      "/var/lib/garage"
    ];

    # Expose Garage S3 API on Tailscale at minio.${tailnet} to avoid breaking existing clients
    services.tsnsrv.services."minio" = {
      toURL = "http://127.0.0.1:3900";
    };

    topology.self = {
      interfaces.tsnsrv-minio = {
        network = tailnet;
        addresses = [ "https://minio.${tailnet}" ];
      };

      services.garage = {
        name = "Garage S3 API";
        details.listen.text = "127.0.0.1:3900";
      };
    };
  };
}
