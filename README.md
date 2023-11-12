# Dom's dotfiles

> There's no place like ~

## Workspace

This workspace follow the folling structure:

```
├── darwin          # Darwin host configurations
├── home-manager    # Home Manager configurations
├── lib             # Local library helpers
├── nixos           # NixOS host configurations
├── overlays        # Nix overlays
├── pkgs            # Nix packages
├── scripts         # Scripts
├── secrets         # Encrypted secrets
├── .sops.yaml      # SOPS configuration
├── flake.nix       # Flake inputs and outputs
└── shell.nix       # Nix development shell
```

## Hosts

The following host are managed by this flake:

|    Hostname     |  OEM  |           Model           |   OS   |    Role     |
| :-------------: | :---: | :-----------------------: | :----: | :---------: |
| `latitude-7390` | DELL  | latitude 7390 Two in One  | NixOS  | Workstation |
|    `burbage`    |  DIY  |        Intel i3-21        | Debian |   Server    |
| `MCCML44WMD6T`  | Apple | Macbook Pro 16-inch, 2019 | MacOS  | Workstation |
|  `iso-console`  |  N/A  |            N/A            | NixOS  | NixOS .iso  |

## Users

| Username       |      Aviable on Hosts       |        Description        |
| :------------- | :-------------------------: | :-----------------------: |
| `dom`          | `latitude-7390` - `burbage` |       Primary user        |
| `dom.egginton` |       `MCCML44WMD6T`        | Work user - extends `dom` |
| `nixos`        |        `iso-console`        |      NixOS .iso user      |

## Installing NixOS

1. Create a bootable .iso image using the `rebuild-iso-console` script, this will leave a live image in the `~/.dotfiles/result/iso/` directory.
2. Burn the .iso image to a USB drive using the `dd` command:

```sh
dd if=~/.dotfiles/result/iso/nixos.iso of=/dev/sdX status=progress oflag=sync bs=4M
```

3. Boot the target computer from the USB drive.
4. Run `install-system <hostname> <username>` from a terminal. The install
   script uses [Disko] to automatically partition and format the disks, then
   uses my flake via `nixos-install` to complete a full-system installation.
   This flake is copied to the target user's home directory as `~/.dotfiles`.
5. Reboot
6. Login and run `rebuild-home` from a terminal to apply the home configuration.

If the target system is booted from something other than the .iso image created by this flake, you can still install the system using the following:

```sh
curl -sL https://raw.githubusercontent.com/dominicegginton/dotfiles/main/scripts/install.sh | bash -s <hostname> <username>
```

## Applying Chanages

Use the following commands to apply changes:

```sh
rebuild-host  # Rebuild and switch to the new NixOS configuration
rebuild-home  # Rebuild and switch to the new Home Manager configuration
```

## Upgrading

Upgrade this flake and rebuild the host and home configurations:

```sh
cd ~/.dotfiles
nix flake update
rebuild-host
rebuils-home
```

## Creating a NixOS .iso image

Use the provided `rebuild-iso-console` script to create a NixOS .iso image with the flake included. A live image will be created in the `~/$HOME/.dotfiles/result/iso/` directory.
