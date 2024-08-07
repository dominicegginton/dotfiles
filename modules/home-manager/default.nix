{ config, lib, pkgs, stateVersion, username, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
in

with lib;

{
  imports = [
    ./applications
    ./console
    ./display
    ./services
  ];

  config = {
    home = {
      inherit stateVersion username;
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      sessionPath = [ "$HOME/.local/bin" ];
      activation.report-changes = config.lib.dag.entryAnywhere ''
        ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
      '';
    };
  };
}
