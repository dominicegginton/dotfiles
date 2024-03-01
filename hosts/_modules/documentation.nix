{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.documentation;
in {
  config = {
    documentation = {
      enable = true;
      man.enable = lib.mkDefault true;
      nixos.enable = lib.mkDefault false;
      info.enable = lib.mkDefault false;
      doc.enable = lib.mkDefault false;
    };
  };
}
