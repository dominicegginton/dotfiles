{ pkgs, config, lib, ... }:

{
  options.display.wio.enable = lib.mkEnableOption "wio";
  config = lib.mkIf config.display.wio.enable {
    environment.systemPackages = with pkgs; [ wio rc plan9port ];
    # services.displayManager.sessionPackages = [ pkgs.wio ];
  };
}
