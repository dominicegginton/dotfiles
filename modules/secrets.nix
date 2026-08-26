{ config, lib, ... }:

let
  userPasswordDefined = (config.users.users.dom.hashedPasswordFile or null) != null;
  userPasswordSet =
    (userPasswordDefined && (config.users.users.dom.hashedPasswordFile != ""))
    || ((config.users.users.dom.hashedPassword or null) != null);
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

    secrets = lib.mkIf (!config.wsl.enable && config.networking.hostName != "infector") (
      let
        hostSopsFile = ../secrets/hosts + "/${config.networking.hostName}.yaml";
        useHostSops = builtins.pathExists hostSopsFile;

        # Helper to set the sopsFile to the host-specific file if it exists,
        # otherwise we return null to filter it out and avoid evaluation errors.
        hostSecret = opt: if useHostSops then { sopsFile = hostSopsFile; } // opt else null;

        # Filter out null values from the secrets attrset
        filterNulls = lib.filterAttrs (_: value: value != null);
      in
      filterNulls {
        # Global secrets (shared across all non-WSL hosts)
        "users/dom/password" = {
          neededForUsers = true;
        };
        "users/dom/u2f_keys" = {
          owner = "dom";
          group = "users";
          mode = "0600";
          path = "/home/dom/.config/Yubico/u2f_keys";
        };
        "services/usbguard/rules" =
          if config.services.usbguard.enable then
            {
              owner = "root";
              group = "root";
              mode = "0600";
              path = "/etc/usbguard/rules.conf";
            }
          else
            null;
        "services/tsnsrv/auth-key" = { };
        "services/beszel/agent" = { };
        "services/gcp-logging/key" =
          if config.services.gcp-logging.enable then
            {
              owner = "vector";
              group = "vector";
            }
          else
            null;

        # Host-specific secrets (only defined/loaded if their host file exists and the service is enabled)
        "services/immich/oauth-secret" = if config.services.immich.enable then hostSecret { } else null;
        "services/immich/gcs-backup-key" = if config.services.immich.enable then hostSecret { } else null;
        "services/silverbullet/gcs-backup-key" =
          if config.services.silverbullet.enable then hostSecret { } else null;
        "services/sssd/client-secret" =
          if (config.users.sssd.enable or false) then hostSecret { } else null;
        "services/frigate/gcs-backup-key" = if config.services.frigate.enable then hostSecret { } else null;
        "services/garage/rpc-secret" =
          if (config.services.garage.enable or false) then hostSecret { } else null;
        "services/hermes/env" = if (config.services.hermes.enable or false) then hostSecret { } else null;
        "services/github/runner-token" =
          if (config.services.residence.githubRunner.enable or false) then
            hostSecret {
              mode = "0400";
              owner = "root";
              group = "root";
            }
          else
            null;
        "services/beszel/hub" =
          if (config.services.beszel.hub.enable or false) then hostSecret { } else null;
        "services/harmonia/sign-key" =
          if config.services.harmonia-custom.enable then hostSecret { } else null;
        "onlyoffice_jwt_secret" =
          if (config.services.onlyoffice-documentserver.enable or false) then hostSecret { } else null;
        "oauth2_proxy_oidc_client_secret" =
          if (config.services.oauth2-proxy-custom.enable or false) then hostSecret { } else null;
        "oauth2_proxy_cookie_secret" =
          if (config.services.oauth2-proxy-custom.enable or false) then hostSecret { } else null;
      }
    );
  };
}
