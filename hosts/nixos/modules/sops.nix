# Sops.
#
# Nix Sops configuration.
{...}: {
  sops.defaultSopsFile = ../../../secrets.yaml;
}
