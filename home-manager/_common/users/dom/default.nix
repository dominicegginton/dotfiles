{ config, lib, hostname, pkgs, username, ... }:

let
  inherit (pkgs) stdenv;
  inherit (lib) mkIf;
in

{
  sops.secrets."dom.github_token" = { };

  imports = [
    ./console
    ./sources
  ];

  home = {
    file.".face".source = ./face.jpg;
    file.".ssh/config".text = "";

    packages = with pkgs; [
      discord
    ];

    sessionVariables = {
      EDITOR = "nvim";
      GITHUB_TOKEN = config.sops.secrets."dom.github_token".path;
    };
  };

  systemd.user.tmpfiles.rules = mkIf stdenv.isLinux [
    "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
