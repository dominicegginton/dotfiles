{ mkShell
, nix
, nixpkgs-fmt
, deadnix
, nix-diff
, nix-tree
, google-cloud-sdk
, opentofu
, writeShellApplication
, bootstrap-nixos-host
}:

mkShell {
  name = "dominicegginton/dotfiles";
  packages = [
    nix
    nixpkgs-fmt
    deadnix
    nix-diff
    nix-tree
    google-cloud-sdk
    opentofu
    (writeShellApplication {
      name = "deploy";
      runtimeInputs = [ opentofu google-cloud-sdk ];
      text = ''
        gcloud auth application-default login
        tofu -chdir=infrastructure init
        tofu -chdir=infrastructure apply -refresh-only 
      '';
    })
    bootstrap-nixos-host
  ];
}
