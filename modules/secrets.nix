{ config, ... }:

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

    # Path to host's dedicated Age key on persistent storage
    age.keyFile = "/persist/var/lib/sops-nix/key.txt";
  };
}
