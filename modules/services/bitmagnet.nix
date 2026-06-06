{
  lib,
  config,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.bitmagnet.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailsclae.enable must be set to true";
      }
    ];

    # Persistent storage for Bitmagnet data
    environment.persistence."/persist".directories = [
      "/var/lib/bitmagnet"
    ];
  };
}
