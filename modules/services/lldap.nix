# TDOO: replace this with kanidm, keycloak or self build ldap implementation
#       llap does not provide posix account schemas out of the box

{
  config,
  lib,
  tailnet,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.lldap.enable {
    systemd.services.lldap-jwt-secret = {
      description = "Generate LLDAP JWT secret";
      wantedBy = [ "multi-user.target" ];
      before = [ "lldap.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /var/lib/lldap
        chmod 700 /var/lib/lldap
        if [ ! -s /var/lib/lldap/jwt_secret ]; then
          ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/lldap/jwt_secret
        fi
        chmod 600 /var/lib/lldap/jwt_secret
      '';
    };

    systemd.services.lldap-user-password = {
      description = "Generate LLDAP admin password";
      wantedBy = [ "multi-user.target" ];
      before = [ "lldap.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /var/lib/lldap
        chmod 700 /var/lib/lldap
        if [ ! -s /var/lib/lldap/user_password ]; then
          ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/lldap/user_password
        fi
        chmod 600 /var/lib/lldap/user_password
      '';
    };

    services.lldap = {
      silenceForceUserPassResetWarning = true;
      settings = {
        ldap_host = "0.0.0.0";
        ldap_port = 3890;
        http_host = "0.0.0.0";
        http_port = 17170;
        http_url = "http://0.0.0.0:17170/";
        ldap_base_dn = "dc=dominicegginton,dc=dev";
        ldap_user_dn = "admin";
        ldap_user_email = "admin@dominicegginton.dev";
        database_url = "sqlite:///var/lib/lldap/users.db?mode=rwc";
        force_ldap_user_pass_reset = "always";
      };
      environment = {
        LLDAP_LDAPS_OPTIONS_ENABLED = "true";
        LLDAP_JWT_SECRET_FILE = "/var/lib/lldap/jwt_secret";
        LLDAP_LDAP_USER_PASS_FILE = "/var/lib/lldap/user_password";
      };
    };

    topology.self.services.lldap = {
      name = config.services.systemd.llap.serviceName;
      details.listen.text = "https://ldap.${tailnet}";
    };
  };
}
