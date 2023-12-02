# There's no place like ~ [<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="125" align="right" alt="NixOS">](https://nixos.org)

> Declarative system configurations using NixOS, NixDarwin, and Home Manager.

## Workspace

This workspace follows the following structure:

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

The following hosts are managed by this flake:

| HOSTNAME        | OEM   | MODEL                     | OS         | ROLE        |
| :-------------- | :---- | :------------------------ | :--------- | :---------- |
| `latitude-7390` | DELL  | Latitude 7390 Two in One  | NixOS      | Workstation |
| `MCCML44WMD6T`  | Apple | Macbook Pro 16-inch, 2019 | MacOS      | Workstation |
| `burbage`       | DIY   | Intel i3-21               | Debian     | Server      |
| `iso-console`   | N/A   | N/A                       | NixOS .iso | NixOS .iso  |

## Users

The following user configurations are managed by this flake and are available across the above hosts:

| Username       | Aviable on Hosts            | Description                                                                            |
| :------------- | :-------------------------- | :------------------------------------------------------------------------------------- |
| `dom`          | `latitude-7390` - `burbage` | [Doms](https://dominicegginton.dev) user account configuration                         |
| `dom.egginton` | `MCCML44WMD6T`              | [Doms](https://dominicegginton.dev) work user account configuration that extends `dom` |
| `nixos`        | `iso-console`               | NixOS .iso user account configuration                                                  |

## Packages

The following derivations are defined by this flake:

| Package                                                                                                     | Description                                                             |
| :---------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| `create-iso-usb`                                                                                            | Creates an bootable nixos iso usb from a build nixos iso configuration. |
| `rebuild`                                                                                                   | Rebuilds the host and home configurations.                              |
| `rebuild-host`                                                                                              | Rebuilds the host configuration.                                        |
| `rebuild-iso-console`                                                                                       | Rebuilds the nixos iso configuration from this flake.                   |
| `shutdown-host`                                                                                             | Shutdown the current host.                                              |
| `rebuild-home`                                                                                              | Rebuilds the home manager configuration.                                |
| `gpg-import-keys`                                                                                           | Imports private gpg keys.                                               |
| `network-filters-disable`                                                                                   | Disables Cisco network filters on darwin hosts.                         |
| `network-filters-enable`                                                                                    | Enable Cisco network filterson darwin hosts.                            |
| [`nodePackages.custom-elements-languageserver`](https://github.com/Matsuuu/custom-elements-language-server) | Provides useful language features for Web Components.                   |

## Installing NixOS Hosts

1. Create a bootable .iso image using the `rebuild-iso-console` script, this
   will leave a live image in the `~/.dotfiles/result/iso/` directory.

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

If the target system is booted from something other than the .iso image created
by this flake, you can still install the system using the following:

```sh
curl -sL https://raw.githubusercontent.com/dominicegginton/dotfiles/main/scripts/install.sh | bash -s <hostname> <username>
```

## Installing NixDarwin Hosts

1. Install the [Nix package manager](https://nixos.org/download#nix-install-macos).

```sh
sh <(curl -L https://nixos.org/nix/install)
```

2. Clone this repository to `~/.dotfiles`:

```sh
git clone https://github.com/dominicegginton/dotfiles.git ~/.dotfiles
```

3. Enter the development shell:

```sh
cd ~/.dotfiles && nix develop
```

4. Apply both host and home configurations with the following:

```sh
rebuild-home
rebuild-host
```

## Applying Changes

Update the configuration and use the following to apply changes:

```sh
rebuild-host  # Rebuild and switch to the new NixOS or NixDarwin configuration
rebuild-home  # Rebuild and switch to the new Home Manager configuration
```

## Upgrading

Upgrade this flake then rebuild the host and home configurations:

```sh
cd ~/.dotfiles
nix flake update
rebuild-host
rebuild-home
```
