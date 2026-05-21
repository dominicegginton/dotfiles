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
    # User-specific secrets
    secrets.${username} = "be2b6a7a-7811-4711-86f0-b24200a41bbd";

    # Primary user configuration
    users.users.${username} = {
      enable = lib.mkDefault true;
      isNormalUser = lib.mkDefault true;
      description = self.outputs.lib.maintainers.dominicegginton.name;
      hashedPasswordFile = "/run/bitwarden-secrets/${username}";
      homeMode = "0755";
      # Group memberships
      extraGroups = [
        "users"
        "wheel" # Sudo access
        "input"
        "audio"
        "video"
        "bluetooth"
        "dav2fs"
        "lpadmin"
        "docker"
        "fuse"
      ];
      # SSH access configuration
      openssh = {
        authorizedPrincipals = [
          "${username}@localhost"
          "${username}@${hostname}"
          self.outputs.lib.maintainers.dominicegginton.email
        ];
        authorizedKeys.keys = self.outputs.lib.maintainers.dominicegginton.sshKeys;
      };
    };

    # Antivirus protection for downloads
    services.clamav.daemon.settings.OnAccessIncludePath = lib.mkDefault "/home/${username}/Downloads";

    # Home Manager integration
    home-manager.users.${username} = ../../home/${username};
  };
}
