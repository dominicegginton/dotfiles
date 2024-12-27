{ stdenv, writers, busybox, gum, jq, bws, ... }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  let
    directory = "/root/bitwarden-secrets";
    mount = "/run/bitwarden-secrets";
  in

  writers.writeBashBin "secrets-sync" ''
    if [ "$(id -u)" != "0" ]; then
      echo "This script must be run as root" 1>&2
      exit 1
    fi
    BWS_PROJECT_ID=$(${gum}/bin/gum input --password --prompt "Bitwarden Secrets Project ID: " --placeholder "********")
    BWS_ACCESS_TOKEN=$(${gum}/bin/gum input --password --prompt "Bitwarden Secrets Access Token: " --placeholder "********")
    ${gum}/bin/gum spin \
      --title "Syncing Secrets" \
      --show-output \
      -- ${bws}/bin/bws secret list "$BWS_PROJECT_ID" \
        --output json \
        --access-token "$BWS_ACCESS_TOKEN" \
        > ${directory}/secrets.json
    secret_ids=$(${jq}/bin/jq -r '.[] | .id' ${directory}/secrets.json)
    for id in $secret_ids; do
      name=$(${jq}/bin/jq -r ".[] | select(.id == \"$id\") | .key" ${directory}/secrets.json)
      value=$(${jq}/bin/jq -r ".[] | select(.id == \"$id\") | .value" ${directory}/secrets.json)
      if [ -z "$name" ] || [ -z "$value" ]; then
        continue
      fi
      echo $value | ${busybox}/bin/sed 's/\\n/\n/g' > ${directory}/secrets/$name
      ${busybox}/bin/chown root:root ${directory}/secrets/$name
      ${busybox}/bin/chmod 600 ${directory}/secrets/$name
      ${busybox}/bin/ln -sf ${directory}/secrets/$name ${mount}/$name
      ${busybox}/bin/chown root:root ${mount}/$name
      ${busybox}/bin/chmod 600 ${mount}/$name
      ${gum}/bin/gum log --level info "Synced secret $name"
    done
  ''
