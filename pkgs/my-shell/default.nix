{ pkgs, ags, system, ... }:

ags.lib.bundle {
  inherit pkgs;
  src = ./.;
  name = "my-shell"; # name of executable
  entry = "app.ts";
  gtk4 = false;
  extraPackages = [
    ags.packages.${system}.battery
    pkgs.fzf
  ];
}
