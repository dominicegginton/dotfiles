{ pkgs, config, lib, ... }:

{
  options.programs.wio.enable = lib.mkEnableOption "wio";
  config = lib.mkIf config.programs.wio.enable {
    environment.systemPackages = with pkgs; [ wio rc plan9port ];
    # services.displayManager.sessionPackages = [ pkgs.wio ];
  };
}
