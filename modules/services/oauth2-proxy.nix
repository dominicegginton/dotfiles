{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.services.oauth2-proxy = {
    enable = mkEnableOption "OAuth2 Proxy";

    port = mkOption {
      type = types.port;
      default = 4180;
      description = "Port the OAuth2 Proxy should listen on.";
    };

    upstream = mkOption {
      type = types.str;
      description = "The upstream URL to proxy to (e.g., http://localhost:8000).";
    };

    oidcIssuerUrl = mkOption {
      type = types.str;
      description = "The OIDC issuer URL (e.g., https://accounts.google.com).";
    };

    oidcClientId = mkOption {
      type = types.str;
      description = "The OIDC client ID.";
    };

    oidcClientSecretFile = mkOption {
      type = types.str;
      description = "Path to a file containing the OIDC client secret.";
    };

    oidcRedirectUrl = mkOption {
      type = types.str;
      description = "The OIDC redirect URL (e.g., https://office.example.com/oauth2/callback).";
    };

    oidcScopes = mkOption {
      type = with types; listOf str;
      default = [
        "openid"
        "profile"
        "email"
      ];
      description = "List of OIDC scopes.";
    };

    cookieSecretFile = mkOption {
      type = types.str;
      description = "Path to a file containing the cookie secret.";
    };

    jwtUpstreamEnable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable passing JWTs to the upstream service.";
    };

    jwtUpstreamSecretFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to a file containing the secret for signing/validating JWTs passed to the upstream.";
    };

    jwtUpstreamHeader = mkOption {
      type = types.str;
      default = "X-Auth-Request-Jwt";
      description = "The header name to use for passing the JWT to the upstream service.";
    };

  };

  config = mkIf config.services.oauth2-proxy.enable {
    services.oauth2-proxy = {
      enable = true;
      httpAddress = "127.0.0.1:${toString config.services.oauth2-proxy.port}";
      upstreams = [ config.services.oauth2-proxy.upstream ];
      provider = "oidc";
      oidcIssuerUrl = config.services.oauth2-proxy.oidcIssuerUrl;
      clientID = config.services.oauth2-proxy.oidcClientId;
      clientSecretFile = config.services.oauth2-proxy.oidcClientSecretFile;
      redirectURL = config.services.oauth2-proxy.oidcRedirectUrl;
      scope = builtins.concatStringsSep " " config.services.oauth2-proxy.oidcScopes;
      cookie.secretFile = config.services.oauth2-proxy.cookieSecretFile;

      extraConfig =
        lib.mkIf config.services.oauth2-proxy.jwtUpstreamEnable {
          "--set-xauthrequest" = "true";
          "--upstream-header" = "${config.services.oauth2-proxy.jwtUpstreamHeader}:${
            config.sops.secrets."${lib.last (
              lib.splitString "/" config.services.oauth2-proxy.jwtUpstreamSecretFile
            )}".path
          }";
          "--jwt-session-header" = "${config.services.oauth2-proxy.jwtUpstreamHeader}";
          "--jwt-session-cookie-name" = "_oauth2_proxy_jwt";
          "--jwt-session-secret" =
            config.sops.secrets."${lib.last (
              lib.splitString "/" config.services.oauth2-proxy.jwtUpstreamSecretFile
            )}".path;
        }
        // {
          # Add any other generic extra config here
        };
      # };
    };

    # Ensure required services are enabled if oauth2-proxy needs them
    # For instance, if oauth2-proxy requires a local Redis for sessions
    # services.redis.enable = mkDefault true;

    # Add a user and group for oauth2-proxy if they are not already defined by the module
    users.users.oauth2-proxy = {
      isSystemUser = true;
      group = "oauth2-proxy";
    };
    users.groups.oauth2-proxy = { };
  };
}
