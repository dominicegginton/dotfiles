[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System Configuration
NixOS / NixDarwin / HomeManager / SopsNix
```

## Features

- **Nix Flakes** 100% Nix Flakes based configuration, no Nix channels.
- **Disk Management** Declarative disk management using Disko.
- **Encrypted Secrets** Stored configuration secrets are encrypted using SopsNix.
- **User Home Environments** Reproducible user home environments using HomeManager.
- **MacOS Hosts** NixDarwin provides support for MacOS hosts.
- **Continuous Integration** Backed by continuous integration workflows on GitHub Actions runners.
- **Nix Dev Shells** Reproducible environments for common tools and tasks.
- **Flake Templates** Easily create new Nix Flakes using templates for common cases.

## Workspace

This workspace follows the following structure:

```
├── home            # Home manager configurations
├── hosts           # Host NixOS and NixDarwin configurations
├── lib             # Nix module helpers
├── modules         # Nix modules
├── overlays        # Nix package overlays
├── pkgs            # Nix packages
├── scripts         # Scripts
├── shells          # Nix development shells
├── templates       # Flake templates
└── flake.nix       # Nix Flake inputs and outputs
```

## Hosts

This workspace defines the following hosts:

<table>
    <tr>
        <th width="100" align="left">HOSTNAME</th>
        <th width="100" align="left">OEM</th>
        <th width="482" align="left">MODEL</th>
        <th width="100" align="left">OS</th>
        <th width="100" align="left">ROLE</th>
    </tr>
    <tr>
        <td>latitude-7390</td>
        <td>DELL</td>
        <td>Latitude 7390 Two in One</td>
        <td>NixOS</td>
        <td>Workstation</td>
    </tr>
    <tr>
        <td>MCCML44WMD6T</td>
        <td>Apple</td>
        <td>Macbook Pro 16-inch, 2019</td>
        <td>MacOS</td>
        <td>Workstation</td>
    </tr>
    <tr>
        <td>burbage</td>
        <td>DIY</td>
        <td>Intel i3-2100</td>
        <td>Debian</td>
        <td>Server</td>
    </tr>
    <tr>
        <td>iso-console</td>
        <td>N/A</td>
        <td>N/A</td>
        <td>NixOS.iso</td>
        <td>NixOS.iso</td>
    </tr>
</table>

## Packages

The workspace includes definitions for the following packages:

<table>
    <tr>
        <th width="200" align="left">Package</th>
        <th width="682" align="left">Description</th>
    </tr>
    <tr>
        <td>create-iso-usb</td>
        <td>Builds an iso image and burns it to a USB drive</td>
    </tr>
    <tr>
        <td>rebuild-configuration</td>
        <td>Rebuilds then switches to the current configuration</td>
    </tr>
    <tr>
        <td>rebuild-host</td>
        <td>Rebuilds then switches to the home manager configuration</td>
    </tr>
    <tr>
        <td>rebuild-home</td>
        <td>Rebuilds then switches to the home manager configuration</td>
    </tr>
    <tr>
        <td>rebuild-iso-console</td>
        <td>Rebuilds the NixOS ISO configuration</td>
    </tr>
    <tr>
        <td>shutdown-host</td>
        <td>Shutdown the current host</td>
    </tr>
    <tr>
        <td>reboot-host</td>
        <td>Reboot the current host</td>
    </tr>
    <tr>
        <td>gpg-import-keys</td>
        <td>Copies GPG keys from google cloud storage then imports them</td>
    </tr>
    <tr>
        <td>network-filters-disable</td>
        <td>Disables Cisco network filters on MacOS</td>
    </tr>
    <tr>
        <td>network-filters-enable</td>
        <td>Enable Cisco network filters on MacOS</td>
    </tr>
</table>

## Development Shells

Reproducible development shell environments are provided for the following common tools and tasks:

<table>
    <tr>
        <th width="200" align="left">Dev Shell</th>
        <th width="682" align="left">Description</th>
    </tr>
    <tr>
        <td>workspace</td>
        <td>Development shell</td>
    </tr>
    <tr>
        <td>web</td>
        <td>Development shell for web development</td>
    </tr>
    <tr>
        <td>python</td>
        <td>Development shell for python and virtualenv</td>
    </tr>
</table>

## Eye Candy

![2024-02-24_09-50](https://github.com/dominicegginton/dotfiles/assets/28626241/658cfb6d-96aa-4692-ad0e-891c7a081a60)

<p align="center">
    <sub>Last Updated: 2024-02-24</sub>
</p>

## Documentation

#### Creating a new NixOS Host

```ocaml
Coming Soon
```

#### Creating a new NixDarwin Host

```ocaml
Coming Soon
```

#### Reinstalling an existing NixOS Host

To reinstall an existing NixOS host on a new target computer, use the following steps:

1. Create a bootable .iso image using the **create-iso-usb** package.
2. Boot the target computer from the USB drive.
3. Run `install-system <hostname> <username>` from a terminal.
4. Reboot the target computer.
5. Login and run `rebuild-home` from a terminal to apply the home manager configuration.

#### Reinstalling an existing NixDarwin Host

To reinstall an existing NixDarwin host, use the following steps:

> [!NOTE]
> Installing Nix on MacOS will create a separate volume exceeding many gigabytes in size.

1. Install the [Nix package manager](https://nixos.org/download#nix-install-macos).
2. Clone this repository to `~/.dotfiles`.
3. Enter the development shell using `nix develop`.
4. Apply the NixDarwin and HomeManager configurations using `rebuild-configuration`.

#### Updating the Host Configuration

```ocaml
Coming Soon
```

#### Updating the Home Manager Configuration

```ocaml
Coming Soon
```

#### Upgrading this Flake

GitHub Actions workflows are used to automatically update the flake inputs
weekly. A pull request is made and the CI workflow will build a virtual machine
or top-level configuration to ensure that upgraded flake inputs result in
successful builds.
