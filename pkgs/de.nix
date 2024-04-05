{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "de";

  text = ''
    if [ -z "$XDG_CURRENT_DESKTOP" ]; then
      echo "No desktop environment set"
      exit 1
    fi

    if pgrep -x "$XDG_CURRENT_DESKTOP" > /dev/null; then
      echo "Desktop environment $XDG_CURRENT_DESKTOP is already running"
      read -p "Do you want to exit the current desktop environment? [y/N] " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        pkill -x "$XDG_CURRENT_DESKTOP"
        exit 0
      else
        exit 0
      fi
    fi

    case $XDG_CURRENT_DESKTOP in
      sway)
        exec sway
        ;;
      *)
        echo "Unknown desktop environment: $XDG_CURRENT_DESKTOP"
        exit 1
        ;;
    esac
  '';
}
