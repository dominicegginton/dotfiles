{
  config,
  lib,
  pkgs,
  tailnet,
  ...
}:

let
  cfg = config.users.sssd;
in

{
  options.users.sssd = {
    enable = lib.mkEnableOption "SSSD with tsidp OAuth2 authentication";
    clientId = lib.mkOption {
      type = lib.types.str;
      default = "sssd";
      description = "OAuth2 Client ID for SSSD";
    };
    userMap = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Mapping of IdP usernames to local usernames (e.g. 'user@example.com:localuser')";
    };
  };

  config = lib.mkIf cfg.enable {
    # Disable legacy LDAP if SSSD is enabled
    users.ldap.enable = lib.mkForce false;

    # SSSD configuration with IdP support (OAuth2)
    # Ref: https://sssd.io/docs/idp/idp-introduction.html
    services.sssd = {
      enable = true;
      sshAuthorizedKeysIntegration = true;
      config = ''
        [sssd]
        services = nss, pam, ssh
        domains = TAILNET
        debug_level = 9

        [nss]
        filter_users = root
        filter_groups = root

        [pam]

        [domain/TAILNET]
        debug_level = 9
        # Use proxy provider to use local /etc/passwd for identity
        id_provider = proxy
        proxy_lib_name = files

        auth_provider = idp
        access_provider = permit

        # SSSD IdP provider still needs these to be set
        ldap_uri = https://idp.${tailnet}
        ldap_search_base = dc=unused

        idp_type = oauth2
        idp_issuer = https://idp.${tailnet}
        idp_token_endpoint = https://idp.${tailnet}/token
        idp_device_auth_endpoint = https://idp.${tailnet}/device/code
        idp_userinfo_endpoint = https://idp.${tailnet}/userinfo
        idp_scope = openid profile
        idp_id_scope = openid
        idp_auth_scope = openid profile
        idp_client_id = ${cfg.clientId}
        idp_client_secret = @${config.sops.secrets."services/sssd/client-secret".path}
        ${lib.optionalString (cfg.userMap != null) "idp_user_map = ${cfg.userMap}"}
      '';
    };

    # Ensure SSSD secret is present
    sops.secrets."services/sssd/client-secret" = {
      owner = "root";
      group = "root";
      mode = "0440"; # Allow group read just in case
    };

    # Enable Keyboard Interactive Authentication for SSH to allow SSSD IdP flow
    services.openssh.settings.KbdInteractiveAuthentication = lib.mkForce true;

    # Include SSSD utilities for debugging
    environment.systemPackages = [ pkgs.sssd ];
  };
}
