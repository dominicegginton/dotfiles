# Dom's dotfiles

> There's no place like ~

## Hosts

|    Hostname     | OEM   |           Model           |   OS   |             Role            |
| :-------------: | :---: | :-----------------------: | :----: | :-------------------------: |
| `latitude-7390` | DELL  | latitude 7390 Two in One  | NixOS  |     Workstation - Laptop    |
|    `burbage`    | DIY   |        Intel i3-21        | Debian |           Server            |
| `MCCML44WMD6T`  | Apple | Macbook Pro 16-inch, 2019 | MacOS  | Workstation - Laptop (Work) |

## Installing NixOS

- Boot off a .iso image created by this flake using `rebuild-iso-console` (_see below_)
- Put the .iso image on a USB drive
- Boot the target computer from the USB drive
- Run `install-system <hostname> <username>` from a terminal
  - The install script uses [Disko] to automatically partition and format the disks, then uses my flake via `nixos-install` to complete a full-system installation
  - This flake is copied to the target user's home directory as `~/.dotfiles`
- Reboot
- Login and run `rebuild-home` (_see below_) from a terminal to complete the Home Manager configuration.

If the target system is booted from something other than the .iso image created by this flake, you can still install the system using the following:

```bash
curl -sL https://raw.githubusercontent.com/dominicegginton/dotfiles/main/scripts/install.sh | bash -s <hostname> <username>
```

## Applying Chanages

Clone this repo to `~/.dotfiles`. NixOS and Home Manager changes are applied separately due to some non-NixOS hosts.

```sh
gh repo clone dominicegginton/dotfiles ~/.dotfiles
```

Use the following commands to apply changes:

```sh
rebuild-host  # Rebuild and switch to the new NixOS configuration
rebuild-home  # Rebuild and switch to the new Home Manager configuration
```

## Creating a NixOS .iso image

Use the provided `rebuild-iso-console` script to create a NixOS .iso image with the flake included. A live image will be created in the `~/$HOME/.dotfiles/result/iso/` directory.
