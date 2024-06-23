# TODO: add configuration options for this module

{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.modules.console.neovim;

in

with lib;

{
  options.modules.console.neovim = {
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra packages to install for neovim";
    };
  };

  config = {
    # TODO: move neovim config into plugin
    # see: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
    programs.neovim = {
      enable = true;
      package = pkgs.neovim;
      viAlias = true;
      vimAlias = true;
      extraPackages = cfg.extraPackages;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SYSTEMD_EDITOR = "nvim";
    };
  };
}
