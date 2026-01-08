{ lib, mkShell, google-cloud-sdk, gh, opentofu, }:

mkShell {
  name = "infrastructure";

  packages = [
    google-cloud-sdk
    gh
    opentofu
  ];

  TF_VAR_gcp_project_id = builtins.getEnv "GCP_PROJECT_ID";
  TF_VAR_github_token = builtins.getEnv "GITHUB_TOKEN";

  meta.maintainers = [ lib.maintainers.dominicegginton ];
}
