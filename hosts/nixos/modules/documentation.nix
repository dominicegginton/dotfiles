# Documentation.
#
# Configures documentation tools and generators.
{lib, ...}: {
  documentation = {
    enable = true;
    man.enable = lib.mkDefault true;
    nixos.enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    doc.enable = lib.mkDefault false;
  };
}
