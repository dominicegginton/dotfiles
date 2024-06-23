# script to ad-doc download the nixpkgs cache index
# see: see: https://github.com/nix-community/nix-index-database?tab=readme-ov-file#ad-hoc-download

{ pkgs }:

pkgs.writeShellApplication {
  name = "download-nixpkgs-cache-index";

  text = ''
    filename="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr '[:upper:]' '[:lower:]')"
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    # -N will only download a new version if there is an update.
    wget -q -N https://github.com/nix-community/nix-index-database/releases/latest/download/"$filename"
    ln -f "$filename" files
  '';

}
