{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # Use the host's SSH key for decryption
    # sops-nix will look for this key on the system
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "users/dom/password" = {
        neededForUsers = true;
      };
      "services/immich/oauth-secret" = { };
    };
  };
}
