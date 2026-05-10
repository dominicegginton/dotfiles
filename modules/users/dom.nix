{
  self,
  lib,
  hostname,
  ...
}:

with lib;

let
  username = "dom";

in

{
  config = {
    secrets.${username} = "be2b6a7a-7811-4711-86f0-b24200a41bbd";

    users.users.${username} = {
      enable = lib.mkDefault true;
      isNormalUser = lib.mkDefault true;
      description = self.outputs.lib.maintainers.dominicegginton.name;
      hashedPasswordFile = "/run/bitwarden-secrets/${username}";
      homeMode = "0755";
      extraGroups = [
        "users" # Standard users group
        "wheel" # For sudo access
        "input" # For keyboard/mouse
        "audio" # For sound
        "video" # For GPU access
        "dav2fs" # For davfs2
        "lpadmin" # For printer admin
        "docker" # For docker access
        "fuse" # For FUSE filesystems
      ];
      openssh = {
        authorizedPrincipals = [
          "${username}@localhost"
          "${username}@${hostname}"
          self.outputs.lib.maintainers.dominicegginton.email
        ];
        authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;
      };
    };

    services.clamav.daemon.settings.OnAccessIncludePath = lib.mkDefault "/home/${username}/Downloads";

    home-manager.users.${username} = ../../home/${username};
  };
}
