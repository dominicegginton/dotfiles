{
  lib,
  config,
  tailnet,
  ...
}:

let
  cfg = config.services.dit0;
in

{
  config = lib.mkIf cfg.enable {
    # Directory Information Tree & LDAP Services
    services.dit0 = {
      base_dn = "dc=T2YHuJgy2121CNTRL,dc=com";
      ldap_port = 636;
      web_port = 443;
      data_dir = "/var/lib/dit0";
      yubico_api_url = "https://api.yubico.com/wsapi/2.0/verify";
      ts_id = "T2YHuJgy2121CNTRL";
      ts_hostname = "dit0";
      ts_api_base_url = "https://api.tailscale.com/api/v2";
      ts_api_key_file = config.sops.secrets."services/dit0/ts-api-key".path;
      ts_auth_key_file = config.sops.secrets."services/dit0/ts-auth-key".path;
    };

    # Persistent storage for the Dit0 LDAP server
    environment.persistence."/persist".directories = lib.mkIf config.impermanence.enable [
      config.services.dit0.data_dir
    ];

    topology.self = {
      interfaces.tsnsrv-dit0 = {
        network = tailnet;
        addresses = [ "https://dit0.${tailnet}" ];
      };

      services.dit0 = {
        name = "Dit0";
        details.listen.text = "https://dit0.${tailnet}";
      };
    };
  };
}
