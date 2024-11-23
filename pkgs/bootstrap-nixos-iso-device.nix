{ writeShellApplication, coreutils, fzf, nixos-generators }:

writeShellApplication {
  name = "bootstrap-nixos-iso-device";
  runtimeInputs = [ coreutils fzf nixos-generators ];

  text = ''
    echo "Building NixOS ISO..."
    nix run github:nix-community/nixos-generators#nixos-generate -- \
      --flake github:dominicegginton/dotfiles#minimal-iso \
      --format iso -o result

    iso=$(find result/iso/*.iso | fzf --header='Select the NixOS ISO to install')
    device=$(lsblk -d -o name \
      | tail -n +2 \
      | fzf --preview 'lsblk -o name,serial,rota,tran,rm,hotplug,ro,type,size,mountpoint' --preview-window=right:60%:wrap --header='Select the device to install NixOS on')

    echo "Installing NixOS on /dev/$device"
    echo "[ALERT] This will erase all data on /dev/$device - Are you sure you want to continue? (Y/n)"
    read -r response
    if [ "$response" != "Y" ]; then
      exit 1
    fi

    echo "Unmounting /dev/$device"
    sudo umount "/dev/$device" || true

    echo "Formatting /dev/$device"
    sudo dd if=/dev/zero of="/dev/$device" bs=1M count=100 status=progress oflag=sync
    sync

    echo "Writing $iso to /dev/$device"
    sudo dd if="$iso" of="/dev/$device" bs=1M status=progress oflag=sync
    sync

    echo "Ejecting /dev/$device"
    sudo eject "/dev/$device"
    sync

    echo "$device is ready"
  '';
}
