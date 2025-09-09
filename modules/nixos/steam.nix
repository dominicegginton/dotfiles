{ pkgs, config, lib, ... }:

{
  config = lib.mkIf config.programs.steam.enable {
    hardware = {
      steam-hardware.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      xone.enable = true;
    };
    programs = {
      steam.gamescopeSession.enable = true;
      xwayland.enable = true;
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
    environment.systemPackages = with pkgs; [ steam-run mangohud ];
  };
}
