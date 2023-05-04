#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

# 1. Get Operating System
OPERATING_SYSTEM=$(uname -s)

# 2. Exit if Operating System is not supported
if [ $OPERATING_SYSTEM != "Darwin" ]; then
  exit 1
fi

CORE_SOFTWARE="bash git stow curl vim"
WORKSTATION_SOFTWARE="nushell git-lfs gh httpie neovim exa ncdu ranger gnupg pinentry pinentry-mac bitwarden-cli yabai skhd wallpaper dominicegginton/formulae/roll dominicegginton/formulae/flip node nvm rust"

# 3. Set up logging variables
CNT="[\033[1;36mNOTE\033[0m]"
COK="[\033[1;32mOK\033[0m]"
CER="[\033[1;31mERROR\033[0m]"
CAT="[\033[1;37mATTENTION\033[0m]"
CWR="[\033[1;35mWARNING\033[0m]"
CAC="[\033[1;33mACTION\033[0m]"

# 4. Clear the screen and print system information
clear
echo "$CNT Operating System: $OPERATING_SYSTEM"
echo "$CNT Operating System Version: $(sw_vers -productVersion)"
echo "$CNT Kernel Version: $(uname -r)"
echo "$CNT Architecture: $(uname -m)"
echo "$CNT Hostname: $(hostname)"
echo "$CNT Username: $(whoami)"
echo "$CNT Home Directory: $HOME"

# 5. Ensure Xcode Command Line Tools are installed
if ! xcode-select -p > /dev/null; then
  echo "$CAC Installing Xcode Command Line Tools"
  xcode-select --install > /dev/null
  if [ $? -ne 0 ]; then
    echo "$CER Xcode Command Line Tools could not be installed"
    exit 1
  fi
fi
echo "$COK Xcode Command Line Tools are installed"

# 6. Ensure Xcode Command Line Tools are up to date
echo "$CAC Checking Xcode Command Line Tools are up to date"
if ! softwareupdate --list > /dev/null; then
  echo "$CAC Updating Xcode Command Line Tools"
  softwareupdate --install --all > /dev/null
  if [ $? -ne 0 ]; then
    echo "$CER Xcode Command Line Tools could not be updated"
    exit 1
  fi
fi
echo "$COK Xcode Command Line Tools are up to date"

# 7. Ensure Homebrew is installed
if ! command -v brew > /dev/null; then
  echo "$CAC Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "$CER Homebrew could not be installed"
    exit 1
  fi
fi
echo "$COK Homebrew is installed"

# 8. Ensure Homebrew is up to date
echo "$CAC Updating Homebrew"
brew update > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Homebrew could not be updated"
  exit 1
fi
echo "$COK Homebrew is up to date"

# 9. Ensure existing Homebrew formulae are up to date
echo "$CAC Upgrading existing Homebrew formulae"
brew upgrade > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Existing Homebrew formulae could not be upgraded"
  exit 1
fi
echo "$COK Existing Homebrew formulae are up to date"

# 10. Ensure Homebrew is ready to brew
echo "$CAC Checking Homebrew is ready to brew"
brew doctor > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Homebrew is not ready to brew"
  exit 1
fi
echo "$COK Homebrew is ready to brew"

# 11. Ensure core software is installed
echo "$CAC Installing core software"
brew install $CORE_SOFTWARE > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Core software could not be installed"
  exit 1
fi
echo "$COK Core software has been installed"

# 12. Stow core dotfiles
echo "$CAC Stowing core dotfiles"
stow -t $HOME core > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Core dotfiles could not be stowed"
  exit 1
fi
echo "$COK Core dotfiles have been stowed"

# 13. Ensure workstation software is installed
echo "$CAC Installing workstation software"
brew install $WORKSTATION_SOFTWARE > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Workstation software could not be installed"
  exit 1
fi
echo "$COK Workstation software has been installed"

# 14. Stow core and MacOS workstation dotfiles
echo "$CAC Stowing workstation dotfiles"
stow -t $HOME workstation-core > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Core Workstation dotfiles could not be stowed"
  exit 1
fi
stow -t $HOME workstation-macos > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER MacOS Workstation dotfiles could not be stowed"
  exit 1
fi
echo "$COK Workstation dotfiles have been stowed"

# 15. Ensure outdated Homebrew formulae are removed from the cellar
echo "$CAC Removing outdated Homebrew formulae from the cellar"
brew cleanup > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Outdated Homebrew formulae could not be removed from the cellar"
  exit 1
fi
echo "$COK Outdated Homebrew formulae have been removed from the cellar"

# 16. Complete installation
echo "$COK Installation complete"
