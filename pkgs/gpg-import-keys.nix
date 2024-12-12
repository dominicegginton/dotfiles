{ writeShellApplication, pinentry, gnupg, google-cloud-sdk }:

writeShellApplication {
  name = "gpg-import-keys";
  runtimeInputs = [ pinentry gnupg google-cloud-sdk ];
  text = ''
    temp=$(mktemp -d)
    cleanup() {
      rm -rf "$temp"
    }
    trap cleanup EXIT
    gcloud auth login
    gsutil rsync -r gs://dominicegginton/gpg "$temp"
    gpg --import "$temp"/*
  '';
}
