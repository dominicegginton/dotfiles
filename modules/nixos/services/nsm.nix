{ pkgs, ... }:

{
  config = {
    environment.variables.NSM_FLAKE = "$HOME/.dotfiles";
    environment.systemPackages = [ pkgs.nsm ];
  };
}
