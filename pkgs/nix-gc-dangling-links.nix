{
  writeShellApplication,
  findutils,
  gum,
  coreutils,
}:

writeShellApplication {
  name = "nix-gc-dangling-links";
  runtimeInputs = [
    findutils
    gum
    coreutils
  ];
  text = ''
    gum log --level info "Searching for dangling Nix store symlinks..."

    links=$(gum spin --spinner dot --title "Scanning..." --show-output -- \
      find "$HOME" -xdev -type l -lname '/nix/store/*' ! -exec test -e {} \; -print 2>/dev/null)

    if [[ -z "$links" ]]; then
      gum style --foreground 2 "No dangling Nix store symlinks found."
      exit 0
    fi

    selected=$(echo "$links" | gum filter --no-limit --header "Select symlinks to delete (TAB to select, Enter to confirm)" || echo "__CANCEL__")

    if [[ "$selected" == "__CANCEL__" ]]; then
      gum style --foreground 3 "Selection cancelled."
      exit 0
    fi

    if [[ -n "$selected" ]]; then
      count=$(echo "$selected" | wc -l)

      if gum confirm "Delete $count selected symlink(s)?"; then
        if echo "$selected" | xargs -d '\n' -r rm -v; then
          gum style --foreground 2 "Successfully deleted $count symlink(s)."
          exit 0
        else
          gum style --foreground 1 "Failed to delete some symlinks."
          exit 1
        fi
      else
        gum style --foreground 3 "Deletion cancelled."
        exit 0
      fi
    else
      gum style --foreground 3 "No symlinks selected."
      exit 0
    fi
  '';
}
