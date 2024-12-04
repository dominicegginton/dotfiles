{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./applications
    ./console
    ./display
    ./services
  ];
}
