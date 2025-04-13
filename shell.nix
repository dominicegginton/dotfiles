{ mkShell
, nix
, deadnix
, google-cloud-sdk
, opentofu
, writeShellApplication
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
    bootstrap-nixos-installer
  ];
}
