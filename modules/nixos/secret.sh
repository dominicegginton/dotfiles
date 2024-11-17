## first argument is the name of the secret name

# wget https://github.com/dominicegginton/dotfiles/raw/main/README.md -O $out
# gcloud auth login
# gcloud secrets versions access latest --secret=$name > $out

bw get password google.com > $out
