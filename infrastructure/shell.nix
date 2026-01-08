{ lib, mkShell, google-cloud-sdk, gh, opentofu, }:

mkShell {
  name = "infrastructure";

  packages = [
    google-cloud-sdk
    gh
    opentofu
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
