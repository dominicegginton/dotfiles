{ mkShell
, nix
, deadnix
, google-cloud-sdk
, opentofu
, bootstrap-nixos-host
, bootstrap-nixos-installer
}:

mkShell {
  name = "dominicegginton/dotfiles";
  packages = [
    nix
    deadnix
    google-cloud-sdk
    opentofu

    bootstrap-nixos-host
    bootstrap-nixos-installer
  ];
}
