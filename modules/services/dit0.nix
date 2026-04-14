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

    # Topology Service Definition
    topology.self.services.dit0 = {
      name = "dit0";
      details.listen.text = "https://dit0.${tailnet}";
    };
  };
}
