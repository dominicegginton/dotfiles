{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs.stdenv) isLinux isDarwin;
in {
  config = {
    console = mkIf isLinux {
      font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
      keyMap = "uk";
      packages = with pkgs; [tamzen];
    };

    programs.zsh =
      if isLinux
      then {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        promptInit = "autoload -U promptinit && promptinit";
      }
      else {
        enable = true;
        enableCompletion = true;
        enableFzfCompletion = true;
        enableFzfGit = true;
        enableFzfHistory = true;
        enableSyntaxHighlighting = true;
        promptInit = "autoload -U promptinit && promptinit";
      };

    environment.systemPackages = with pkgs;
      [
        git
        fzf
      ]
      ++ optionals isLinux [
        pinentry
      ]
      ++ optionals isDarwin [
        pinentry_mac
        network-filters-disable
        network-filters-enable
      ];
  };
}
