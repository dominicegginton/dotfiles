# Dom's dotfiles

My dotfiles are managed by [stow](https://www.gnu.org/software/stow/).

## Packages

> A package is a related collection of files and directories that you wish to administer as a unit - [gnu.org](https://www.gnu.org/software/stow/manual/stow.html#Terminology)

- **core** _Core system configuration_ 
- **server** _System configuration for servers_
- **workstation-core** _Core system configuration for workstation_
- **workstation-linux** _System configuration for workstation on the Linux platform_
- **workstation-macos** _System configuration for workstation on macOS platform_

## Installation

``` shell
git clone https://github.com/dominicegginton/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow {package}
```
