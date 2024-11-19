# TODO: clean up this entrie file

{ config, lib, pkgs, ... }:

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
        vscode.enable = true;
      };
    };

    home.packages =
      with pkgs;
      [ bitwarden-cli discord unstable.jetbrains.webstorm unstable.jetbrains.rust-rover ]
      ++ (if isLinux then [ whatsapp-for-linux telegram-desktop thunderbird unstable.teams-for-linux unstable.chromium unstable.microsoft-edge ]
      else [ ])
      ++ (if isDarwin then [ ]
      else [ ]);
  };
}
