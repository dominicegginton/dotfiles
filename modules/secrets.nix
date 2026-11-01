{ config, lib, ... }:

let
  hasHashedPasswordFile = u: (u.hashedPasswordFile or null) != null && u.hashedPasswordFile != "";
  hasHashedPassword = u: (u.hashedPassword or null) != null;
  hasPlainTextPassword = u: (u.password or null) != null;
  hasInitialPassword = u: (u.initialPassword or null) != null;

  userHasPassword = u:
    hasHashedPasswordFile u
    || hasHashedPassword u
    || hasPlainTextPassword u
    || hasInitialPassword u;

  anyUserPasswordSet = config: lib.any userHasPassword (lib.attrValues config.users.users);
  hasSecretsDefined = config: (config.sops.secrets or { }) != { };
in

{
  assertions = [
    {
      assertion = !hasSecretsDefined config || anyUserPasswordSet config;
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
