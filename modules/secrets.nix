{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # Use the host's SSH key for decryption
    # sops-nix will look for this key on the system
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = lib.mkIf (!config.wsl.enable) ({
      "users/dom/password" = {
        neededForUsers = true;
      };
      "services/immich/oauth-secret" = { };
      "services/immich/gcs-backup-key" = { };
      "services/silverbullet/gcs-backup-key" = { };
      "services/frigate/gcs-backup-key" = { };
      "services/hermes/env" = { };
      "services/github/runner-token" = {
        mode = "0400";
        owner = "root";
        group = "root";
      };
    });
  };
}
