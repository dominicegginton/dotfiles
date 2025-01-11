# TODO: clean up this entrie file

{ pkgs, ... }:

let
  inherit (pkgs.stdenv) isLinux;
in

{
  config = {
    home.file = {
      ".face".source = ./face.jpg;
      ".config".source = ./sources/.config;
      ".config".recursive = true;
      ".arup.gitconfig".source = ./sources/.arup.gitconfig;
      ".editorconfig".source = ./sources/.editorconfig;
      ".gitconfig".source = ./sources/.gitconfig;
      ".gitignore".source = ./sources/.gitignore;
      ".gitmessage".source = ./sources/.gitmessage;
    };

    home.packages = with pkgs; [ ]
      ++ (if isLinux then [
      bitwarden-cli
      whatsapp-for-linux
      telegram-desktop
      thunderbird
      unstable.teams-for-linux
      unstable.chromium
      unstable.microsoft-edge
    ]
    else [ ]);
  };
}
