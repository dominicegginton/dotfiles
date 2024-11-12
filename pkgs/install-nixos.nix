{ pkgs }:

pkgs.writeShellApplication {
  name = "install-nixos";

  text = ''
    set -e

    device=$(lsblk -d -o name \
      | tail -n +2 \
      | fzf --preview 'lsblk -o name,serial,rota,tran,rm,hotplug,ro,type,size,mountpoint' --preview-window=right:60%:wrap --header='Select the device to install NixOS on')

    echo "Selected device: $device"
  '';
}
