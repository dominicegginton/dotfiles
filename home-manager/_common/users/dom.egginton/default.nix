{ pkgs, ... }:

{
  imports = [
    ../dom
  ];

  home = {
    packages = with pkgs; [
      network-filters-enable
      network-filters-disable
    ];

    sessionVariables = { };
  };

  programs = { };
}
