{ stdenv, lib, writers, ensure-user-is-root, nix, util-linux, coreutils, busybox, gum }:

if (!stdenv.isLinux)
then throw "This script can only be run on linux hosts"
else

  writers.writeBashBin "bootstrap-nixos-installer" ''
    export PATH=${lib.makeBinPath [ ensure-user-is-root nix util-linux coreutils busybox gum ]}
    set -efu -o pipefail
    ensure-user-is-root
    device=$(lsblk -d -o name | tail -n +2 | gum choose --header "Select a device to write the NixOS ISO to")
    nix build .#nixosConfigurations.nixos-installer.config.system.build.isoImage
    deviration=$(nix eval .#nixosConfigurations.nixos-installer.config.system.build.isoImage --raw)
    iso=$(find $deviration/iso -type f -name "*.iso" | head -n 1)
    gum confirm "Format all data on /dev/$device and write nixos-installer image - Are you you sure you want to continue?" || exit 1
    gum confirm "Format all data on /dev/$device and write nixos-installer image - Are you you sure you are sure?" || exit 1
    umount "/dev/$device" > /dev/null 2>&1 || true
    gum spin \
      --show-output \
      --title "Writing $iso to /dev/$device" \
      -- dd if="$iso" of="/dev/$device" bs=4M status=progress \
      && eject "/dev/$device" \
      && sync \
      && gum log --level info "Done writing $iso to /dev/$device" \
      || gum log --level error "Failed to write $iso to /dev/$device"
  ''
