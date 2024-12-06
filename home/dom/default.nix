# TODO: clean up this entrie file

{ config, pkgs, ... }:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
in

{
  # TODO: see todo items in the file
  imports = [ ./sources ];

  config = {
    home.persistence."/persistent/home/dom" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        ".gnupg"
        ".ssh"
        ".local/share/keyrings"
        { directory = ".local/share/Steam"; method = "symlink"; }
      ];
      files = [ ];
      allowOther = true;
    };
    home.packages =
      with pkgs; [ bitwarden-cli ]
        ++ (if isLinux then [ whatsapp-for-linux telegram-desktop thunderbird unstable.teams-for-linux unstable.chromium unstable.microsoft-edge ]
      else [ ])
        ++ (if isDarwin then [ ]
      else [ ]);
  };
}
