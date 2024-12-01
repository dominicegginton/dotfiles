{ pkgs, config, lib, ... }:

let
  cfg = config.modules.programs.steam;
in

with lib;

{
  options.modules.programs.steam.enable = mkEnableOption "steam";

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    environment.systemPackages = with pkgs; [ steam-run mangohud ];
  };
}
