{ pkgs, config, lib, ... }:

{
  config = lib.mkIf config.programs.steam.enable {
    hardware.steam-hardware.enable = true;
    hardware.xone.enable = true;
    environment.systemPackages = with pkgs; [ steam-run mangohud ];
    programs.steam.gamescopeSession.enable = true;
  };
}
