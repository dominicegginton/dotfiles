{
  lib,
  config,
  ...
}:

let
  cfg = config.services.bitmagnet;
in

{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.tailscale.enable;
        message = "services.tailsclae.enable must be set to true";
      }
    ];

    # Persistent storage for Bitmagnet data
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      "/var/lib/bitmagnet"
    ];
  };
}
