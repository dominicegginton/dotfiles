{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "create-iso-usb";

  runtimeInputs = with pkgs; [
    nix
    workspace.rebuild-iso-console
  ];

  text = ''
    usage() {
      echo "Usage: ${name} <usb-device>"
    }
    if [ -z "$1" ]; then
      echo "Must provide usb device"
      usage
      exit 1
    fi
    if [ -z "$(ls ~/.dotfiles/result/iso/nixos.iso)" ]; then
      echo "No iso found"
      rebuild-iso-console
    fi
    pushd "$HOME"/.dotfiles
      dd if=~/.dotfiles/result/iso/nixos.iso of=/dev/"$1" status=progress oflag=sync bs=4M
    popd
  '';
}
