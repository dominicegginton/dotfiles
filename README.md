[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System Configuration 
NixOS / NixDarwin / Home Manager
```

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
| `burbage`       | DIY   | Intel i3-2100             | Debian     | Server      |
| `iso-console`   | N/A   | N/A                       | NixOS.iso  | NixOS.iso   |

## Users

The following user configurations are managed by this flake and are available across the above hosts:

| Username       | Aviable on Hosts            | Description                                                                            |
| :------------- | :-------------------------- | :------------------------------------------------------------------------------------- |
| `dom`          | `latitude-7390` - `burbage` | [Doms](https://dominicegginton.dev) user account configuration                         |
| `dom.egginton` | `MCCML44WMD6T`              | [Doms](https://dominicegginton.dev) work user account configuration that extends `dom` |
| `nixos`        | `iso-console`               | NixOS .iso user account configuration                                                  |

## Packages

The following derivations are defined by this flake:

| Package                                                                                        | Description                                                             |
| :--------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| `create-iso-usb`                                                                               | Creates an bootable nixos iso usb from a build nixos iso configuration  |
| `rebuild-configuration`                                                                        | Runs `rebuild-host` then `rebuild-home`                                 |
| `upgrade-configuration`                                                                        | Upgrades the flake then runs `rebuild-configuration`                    |
| `rebuild-host`                                                                                 | Rebuilds then switchs to the NixOs or NixDarwin configuration           |
| `rebuild-home`                                                                                 | Rebuilds then switches to the home manager configuration                |
| `rebuild-iso-console`                                                                          | Rebuilds the nixos iso configuration                                    |
| `shutdown-host`                                                                                | Shutdown the current host                                               |
| `gpg-import-keys`                                                                              | Imports private gpg keys                                                |
| `network-filters-disable`                                                                      | Disables Cisco network filters                                          |
| `network-filters-enable`                                                                       | Enable Cisco network filters                                            |
| [`custom-elements-languageserver`](https://github.com/Matsuuu/custom-elements-language-server) | Provides useful language features for Web Components                    |

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
rebuild-configuration
```

## Applying Changes

Apply changes to the configuration then use one of the following to commands to
rebuild and switch to the new configuration:

```sh
rebuild-host
rebuild-home
rebuild-configuration
```

## Upgrading

Upgrade this flake then rebuild the host and home configurations using the
following command:

```sh
upgrade-configuration # Upgrade the flake then run rebuild-configuration 
```

## Eye Candy

![screenshot_2023-12-09-211721](https://github.com/dominicegginton/dotfiles/assets/28626241/23eb9977-9625-40d4-95f2-56afa61d10cd)
![screenshot_2023-12-09-212003](https://github.com/dominicegginton/dotfiles/assets/28626241/62d9ee95-bff5-4448-a9b5-cbb612a5e408)
