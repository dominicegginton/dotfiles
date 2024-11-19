{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./applications
    ./console
    ./display
    ./services
  ];

  config = {
    sops.defaultSopsFile = ../../secrets.yaml;
    home = {
      stateVersion = "24.05";
      activation.report-changes = config.lib.dag.entryAnywhere ''
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      '';
    };
  };
}
