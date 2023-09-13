{ pkgs, ... }:

{
  users.users.dom = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  home-manager.users.dom = {
    imports = [
      ../../home-manager/home.nix
    ];
  };
}
