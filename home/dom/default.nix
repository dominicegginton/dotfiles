{ lib, pkgs, hostname, ... }:

{
  config = {
    home.file = {
      ".aws/config".source = lib.mkIf (hostname == "latitude-7390" || hostname == "MCCML44WMD6T") ./sources/.aws/config;
      ".face".source = ./face.jpg;
      ".config".source = ./sources/.config;
      ".config".recursive = true;
      ".arup.gitconfig".source = ./sources/.arup.gitconfig;
      ".editorconfig".source = ./sources/.editorconfig;
      ".gitconfig".source = ./sources/.gitconfig;
      ".gitignore".source = ./sources/.gitignore;
      ".gitmessage".source = ./sources/.gitmessage;
      ".ideavimrc".source = lib.mkIf (hostname == "latitude-7390" || hostname == "MCCML44WMD6T") ./sources/.ideavimrc;
    };

    home.packages = with pkgs; lib.mkIf (pkgs.stdenv.isLinux && hostname == "latitude-7390") [
      unstable.teams-for-linux
      jetbrains.datagrip
      jetbrains.webstorm
      unstable.nodejs
    ];
  };
}
