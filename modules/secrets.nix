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
    defaultSopsFile = ../secrets/global.yaml;
    defaultSopsFormat = "yaml";

    # Use the host's SSH key for decryption
    # sops-nix will look for this key on the system
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = lib.mkIf (!config.wsl.enable && config.users.users ? dom) (
      let
        hostSopsFile = ../secrets/hosts + "/${config.networking.hostName}.yaml";
        useHostSops = builtins.pathExists hostSopsFile;

        # Helper to set the sopsFile to the host-specific file if it exists,
        # otherwise we return null to filter it out and avoid evaluation errors.
        hostSecret = opt: if useHostSops then { sopsFile = hostSopsFile; } // opt else null;

        # Filter out null values from the secrets attrset
        filterNulls = lib.filterAttrs (name: value: value != null);
      in
      filterNulls {
        # Global secrets (shared across all non-WSL hosts)
        "users/dom/password" = {
          neededForUsers = true;
        };
        "services/tsnsrv/auth-key" = { };
        "services/beszel/agent" = { };

        # Host-specific secrets (only defined/loaded if their host file exists)
        "services/immich/oauth-secret" = hostSecret { };
        "services/immich/gcs-backup-key" = hostSecret { };
        "services/silverbullet/gcs-backup-key" = hostSecret { };
        "services/sssd/client-secret" = hostSecret { };
        "services/frigate/gcs-backup-key" = hostSecret { };
        "services/garage/rpc-secret" = hostSecret { };
        "services/hermes/env" = hostSecret { };
        "services/github/runner-token" = hostSecret {
          mode = "0400";
          owner = "root";
          group = "root";
        };
        "services/beszel/hub" = hostSecret { };
        "onlyoffice_jwt_secret" = hostSecret { };
        "oauth2_proxy_oidc_client_secret" = hostSecret { };
        "oauth2_proxy_cookie_secret" = hostSecret { };
      }
    );
  };
}
