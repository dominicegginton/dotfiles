{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.modules.services.steam;
in

with lib;

{
  options.modules.services.steam.enable = mkEnableOption "deluge";

  config = mkIf cfg.enable {

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    environment.systemPackages = with pkgs; [
      steam-run
    ];
  };
}
