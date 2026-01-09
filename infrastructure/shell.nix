{ lib, mkShell, google-cloud-sdk, gh, opentofu, }:

mkShell {
  name = "infrastructure";

  packages = [
    google-cloud-sdk
    gh
    opentofu
  ];

  shellHook = ''
    gh auth refresh -s admin:org -s repo
    export TF_VAR_github_pat="$(gh auth token)"
  '';

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
