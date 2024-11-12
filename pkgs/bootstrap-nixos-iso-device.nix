{ pkgs }:

pkgs.writeShellApplication {
  name = "bootstrap-nixos-iso-device";
  runtimeInputs = with pkgs; [ coreutils fzf nixos-generators ];
  text = ''
    echo "Building NixOS ISO..."
    nix run github:nix-community/nixos-generators#nixos-generate -- \
      --flake github:dominicegginton/dotfiles.#minimal-iso \
      --format iso -o result

    device=$(lsblk -d -o name \
      | tail -n +2 \
      | fzf --preview 'lsblk -o name,serial,rota,tran,rm,hotplug,ro,type,mountpoint' --preview-window=right:60%:wrap --header='Select the device to install NixOS on')

    echo "Installing NixOS on /dev/$device"
    echo "This will erase all data on /dev/$device"
    echo "Are you sure you want to continue? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
      echo "Aborting..."
      exit 1
    fi

    sudo dd if=/dev/zero of="/dev/$device" bs=1M count=100 status=progress oflag=sync
    sync

    echo "$device is ready to eject"
  '';
}
