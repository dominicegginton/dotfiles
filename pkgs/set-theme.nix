{ lib, stdenv, writeShellScriptBin, ensure-user-is-not-root, busybox, kdePackages, gum, ... }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  writeShellScriptBin "set-theme" ''
    export PATH=${lib.makeBinPath [ ensure-user-is-not-root busybox kdePackages.plasma-workspace gum ]}
    set -efu -o pipefail
    ensure-user-is-not-root
    theme=$(gum choose --height 15 "light" "dark")
    # echo $theme > /etc/theme
    if [ "$DESKTOP_SESSION" == "plasma" ]; then
      lookandfeel=$(if [ "$theme" == "light" ]; then echo "org.kde.breeze.desktop"; else echo "org.kde.breezedark.desktop"; fi)
      plasma-apply-lookandfeel -a $lookandfeel
    fi
    cp "$HOME/alacritty-$theme-theme.toml" "$HOME/.config/alacritty/alacritty-theme.toml"
  ''
