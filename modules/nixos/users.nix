# TODO: tidy this

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.users;
in

with lib;

{
  options.modules.users = {
    dom.enable = mkEnableOption "Dominic Egginton";
    nixremote.enable = mkEnableOption "Nix Remote";
    nixos.enable = mkEnableOption "NixOS";
  };

  config = {
    sops.secrets."dom.password".neededForUsers = true;

    users.users = {
      dom = mkIf cfg.dom.enable {
        description = "Dominic Egginton";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."dom.password".path;
        homeMode = "0755";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "audio"
          "input"
          "users"
          "video"
          "docker"
        ];
      };

      nixremote = mkIf cfg.nixremote.enable {
        description = "Nix Remote";
        isNormalUser = mkDefault true;
        group = mkDefault "nixremote";
        home = mkDefault "/var/empty";
        createHome = mkDefault false;
      };

      nixos = mkIf cfg.nixos.enable {
        description = "NixOS";
        isNormalUser = mkDefault true;
        home = mkDefault "/var/empty";
        createHome = mkDefault false;
      };

      root = {
        description = "System administrator";
        isNormalUser = mkDefault false;
        hashedPassword = mkDefault null;
      };
    };
  };
}
