# TODO: clean up this entrie file
#       default.nix
#       /console
#       /desktop
#       /desktop/applications
#       /services

{ config, lib, pkgs, username, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) mkIf;
in

{
  # TODO: see todo items in the file
  imports = [ ./sources ];

  config = {
    modules.services.syncthing.enable = mkIf isLinux true;

    modules.display = {
      enable = true;
      plasma.enable = mkIf isLinux true;
      applications = {
        firefox = mkIf isLinux {
          enable = true;
          package = pkgs.firefox-devedition-bin;
        };
        alacritty.enable = true;
        vscode.enable = true;
      };
    };

    systemd.user.tmpfiles.rules = mkIf isLinux [
      "d ${config.home.homeDirectory}/dev/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/playgrounds/ 0755 ${username} users - -"
      "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    ];

    home.packages =
      with pkgs;
      [ bitwarden-cli discord ]
      ++ (if isLinux then [ whatsapp-for-linux telegram-desktop thunderbird unstable.teams-for-linux unstable.chromium unstable.zed-editor unstable.gh-copilot ]
      else [ ])
      ++ (if isDarwin then [ ]
      else [ ]);
  };
}
