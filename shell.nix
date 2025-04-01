{ mkShell, nix, deadnix, bootstrap-nixos-host, bootstrap-nixos-installer }:

mkShell {
  name = "dominicegginton/dotfiles";
  packages = [ nix deadnix bootstrap-nixos-host bootstrap-nixos-installer ];
}
