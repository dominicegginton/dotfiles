<h1 align='center'>Dom's dotfiles</h1>

<h4 align='center'>There's no place like ~</h4>

<div align='center'>
  <img src='assets/linux.svg' width='50'>
  <img src='assets/macos.svg' width='50'>
  <br><br>
</div>

Dotfiles are the files used to store user-specific application configuration. This repository contains my ever-evolving dotfiles that are used to configure software across both the **Linux** and **MacOS** platforms. I'm mainly a **Linux** guy but feel comfortable switching it up when the situation calls for it. This repository allows me to easily store, manage and access my dotfiles, even when faced with a fresh environment I can be set up in minutes making me feel at `~` once again. My dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/), a *free* and *open source* symlink farm manager. A collection of background images I use can be found on my [Unsplash](https://unsplash.com/collections/84737312/backgrounds) account, if you choose to use any images, please credit and thank the photographer. Feel free to clone, use and modify my dotfiles as you see fit, but **please read and understand all configuration files you use before blindly using them on your own system**.

## Packages
- **alacritty** *alacritty configuration and theme*
- **background** *desktop background*
- **bash** *bash configuration with git status*
- **drive** *google drive client for linux configuration*
- **fish** *fish configuration, variables and functions*
- **gh** *gitthub cli configuration*
- **git** *git configuration*
- **htop** *htop system monitor configuration*
- **i3** *configuration and theme files for i3, i3 status, xorg, picom, rofi, dunst, and betterlockscreen*
- **neofetch** *neofetch configuration*
- **ssh** *ssh configuration file*
- **zsh** *zsh configuration with git status*

## Installation

``` shell
$ git clone https://github.com/dominicegginton/dotfiles ~/.dotfiles
$ cd ~/.dotfiles
$ stow {package}
```

## Bugs

I want my dotfiles to work for everyone; that means when you clone and install them they should just work. That said, I use this repository for my personal evolving dotfiles, so there's a good chance I may break something. If you run into any problems or bug when installing or using these dotfiles please feel free to open a [GitHub Issue](https://github.com/dominicegginton/dotfiles/issues/new) on this repository and I'd love to get it fixed for you.