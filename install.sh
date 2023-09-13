#!/bin/sh -e

confirm_password() {
	stty -echo
	until [ "$pass1" = "$pass2" ] && [ "$pass2" ]; do
		printf "%s: " "$1" >&2 && read -r pass1 && printf "\n" >&2
		printf "confirm %s: " "$1" >&2 && read -r pass2 && printf "\n" >&2
	done
	stty echo
	echo "$pass2"
}

# Choose disk
while :; do
	lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
	printf "\nDisk (e.g. /dev/sda): " && read -r my_disk
	[ -b "$my_disk" ] && break
done

cryptpass=$(confirm_password "encryption password")

case "$my_disk" in
*"nvme"*)
	part1="$my_disk"p1
	part2="$my_disk"p2
	;;
*)
	part1="$my_disk"1
	part2="$my_disk"2
	;;
esac

# Partition
printf "label: gpt\n,550M,U\n,,\n" | sfdisk "$my_disk"

# Encrypt
yes "$cryptpass" | cryptsetup -q luksFormat "$part2"
yes "$cryptpass" | cryptsetup open "$part2" root

# Format
mkfs.fat -F 32 "$part1"

mkfs.btrfs /dev/mapper/root
mkdir -p /mnt
mount /dev/mapper/root /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/swap
umount /mnt

# Mount
mount -o compress=zstd,subvol=root /dev/mapper/root /mnt
mkdir /mnt/home
mkdir /mnt/nix
mkdir /mnt/swap
mount -o compress=zstd,subvol=home /dev/mapper/root /mnt/home
mount -o compress=zstd,noatime,subvol=nix /dev/mapper/root /mnt/nix
mount -o noatime,nodatacow,subvol=swap /dev/mapper/root /mnt/swap

mkdir /mnt/boot
mount "$part1" /mnt/boot

# Swapfile
btrfs filesystem mkswapfile -s 4G /mnt/swap/swapfile

# NixOS
nixos-generate-config --root /mnt

nixos-install
