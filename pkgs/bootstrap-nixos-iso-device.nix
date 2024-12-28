{ writeShellApplication, ensure-user-is-root, coreutils, fzf, image-installer-nixos-stable }:

writeShellApplication {
  name = "bootstrap-nixos-iso-device";
  runtimeInputs = [ coreutils fzf ];
  text = ''
    ensure-user-is-root
    device=$(lsblk -d -o name \
      | tail -n +2 \
      | fzf --preview 'lsblk -o name,serial,rota,tran,rm,hotplug,ro,type,size,mountpoint' --preview-window=right:60%:wrap --header='Select the device to install NixOS on')
    iso=$(find ${image-installer-nixos-stable}/iso -name '*.iso' | fzf --header='Select the NixOS ISO to install')
    response=$(echo "Yes No" | tr " " "\n" | fzf --prompt "This will erase all data on /dev/$device - Are you sure you want to continue? ")
    if [ "$response" != "Yes" ]; then
      exit 1
    fi
    echo "Unmounting /dev/$device"
    sudo umount "/dev/$device" || true
    echo "Formatting /dev/$device"
    sudo dd if=/dev/zero of="/dev/$device" count=1 status=progress
    sync
    echo "Writing $iso to /dev/$device"
    sudo dd if="$iso" of="/dev/$device" status=progress
    sync
    echo "Ejecting /dev/$device"
    sudo eject "/dev/$device"
    sync
  '';
}
