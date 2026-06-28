{ config, lib, ... }:

let
  userPasswordDefined = (config.users.users.dom.hashedPasswordFile or null) != null;
  userPasswordSet = userPasswordDefined && (config.users.users.dom.hashedPasswordFile != "");
  secretsDefined = (config.sops.secrets or { }) != { };
in

{
  assertions = [
    {
      assertion = !secretsDefined || userPasswordSet;
      message = "Secrets must not be deployed to hosts where the user password is not set.";
    }
  ];
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # Use the host's SSH key for decryption
    # sops-nix will look for this key on the system
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = lib.mkIf (!config.wsl.enable && config.users.users ? dom) ({
      "users/dom/password" = {
        neededForUsers = true;
      };
      "services/immich/oauth-secret" = { };
      "services/immich/gcs-backup-key" = { };
      "services/silverbullet/gcs-backup-key" = { };
      "services/tsnsrv/auth-key" = { };
      "services/sssd/client-secret" = { };
      "services/frigate/gcs-backup-key" = { };
      "services/hermes/env" = { };
      "services/github/runner-token" = {
        mode = "0400";
        owner = "root";
        group = "root";
      };
      "services/beszel/agent" = { };
      "services/beszel/hub" = { };
      "onlyoffice_jwt_secret" = { };
      "oauth2_proxy_oidc_client_id" = { };
      "oauth2_proxy_oidc_client_secret" = { };
      "oauth2_proxy_cookie_secret" = { };
    });
  };
}
