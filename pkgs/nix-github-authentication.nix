{
  lib,
  writeShellScriptBin,
  coreutils,
  nix,
  gh,
  gum,
}:

writeShellScriptBin "nix-github-authentication" ''
  PATH=${
    lib.makeBinPath [
      coreutils
      nix
      gh
      gum
    ]
  }
  set -euo pipefail

  user=$(id -u)
  username=$(id -un)
  userString="user $username (UID: $user)"

  gum log "Authenticating Nix for $userString with GitHub"

  gh auth status || gh auth login

  GITHUB_TOKEN="$(gh auth token)"

  mkdir -p ~/.config/nix
  if grep -q "access-tokens = github.com=" ~/.config/nix/nix.conf 2>/dev/null; then
    sed -i.bak "s/access-tokens = github.com=.*/access-tokens = github.com=$GITHUB_TOKEN/" ~/.config/nix/nix.conf
  else
    echo "access-tokens = github.com=$GITHUB_TOKEN" >> ~/.config/nix/nix.conf
  fi

  gum log "Nix is now authenticated with GitHub for $userString"
  gum log "The local $userString now has a GitHub access token configured for Nix."
''
