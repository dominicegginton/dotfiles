# TODO: move secrets from tf-state to only secret manager
#       tate currently secured by gcp iam roles

{ lib, mkShell, google-cloud-sdk, gh, opentofu, }:

mkShell {
  name = "dominicegginton/dotfiles/infrastructure";

  packages = [
    google-cloud-sdk
    gh
    opentofu
  ];

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
