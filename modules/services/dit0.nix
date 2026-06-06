{
  lib,
  config,
  tailnet,
  ...
}:

{
  config = lib.mkIf config.services.dit0.enable {
    # Directory Information Tree & LDAP Services
    services.dit0 = {
      base_dn = "dc=T2YHuJgy2121CNTRL,dc=com";
      ldap_port = 636;
      web_port = 443;
      data_dir = "/var/lib/dit0";
      otp_hmac_key_file = "/run/secrets/otp_hmac_key";
      tailscale = {
        id = "T2YHuJgy2121CNTRL";
        hostname = "dit0";
        api_base_url = "https://api.tailscale.com/api/v2";
        api_key_file = "/run/secrets/ts_api_key";
      };
    };

    # Persistent storage for the Dit0 LDAP server 
    environment.persistence."/persist".directories = [
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
