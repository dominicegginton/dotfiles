{ pkgs, config, lib, ... }:

{
  config = lib.mkIf config.programs.steam.enable {
    hardware.steam-hardware.enable = true;
    environment.systemPackages = with pkgs; [ steam-run mangohud ];
  };
}
