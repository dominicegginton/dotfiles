#!/usr/bin/env sh

# Dotfiles By Dominic Egginton
# https://github.com/dominicegginton/dotfiles
# There's no place like ~

# CORE SOFTWARE
CORE_SOFTWARE[0]="bash" # bourne again shell
CORE_SOFTWARE[1]="stow" # symlink farm manager
CORE_SOFTWARE[2]="vim" # text editor
CORE_SOFTWARE[3]="curl" # transfer data from or to a server
CORE_SOFTWARE[4]="git" # version control system

# WORKSTATION CORE SOFTWARE
WORKSTATION_CORE_SOFTWARE[0]="zsh" # z shell
WORKSTATION_CORE_SOFTWARE[1]="git-lfs" # git large file storage
WORKSTATION_CORE_SOFTWARE[2]="neovim" # text editor
WORKSTATION_CORE_SOFTWARE[4]="rust" # rust programming language
WORKSTATION_CORE_SOFTWARE[5]="gpg" # gpg

# WORKSTATION MACOS SOFTWARE
WORKSTATION_MACOS_SOFTWARE[0]="node" # javascript runtime
WORKSTATION_MACOS_SOFTWARE[1]="bitwarden-cli" # password manager
WORKSTATION_MACOS_SOFTWARE[2]="pinentry" # gpg pinentry
WORKSTATION_MACOS_SOFTWARE[3]="pinentry-mac" # gpg pinentry for macos
WORKSTATION_MACOS_SOFTWARE[4]="yabai" # tiling window manager
WORKSTATION_MACOS_SOFTWARE[5]="skhd" # hotkey daemon
WORKSTATION_MACOS_SOFTWARE[6]="wallpaper" # wallpaper manager
WORKSTATION_MACOS_SOFTWARE[7]="dominicegginton/formulae/roll" # roll dice in the terminal
WORKSTATION_MACOS_SOFTWARE[8]="dominicegginton/formulae/flip" # flip a coin in the terminal

# EXIT IF NOT MACOS
OPERATING_SYSTEM=$(uname -s)
if [ $OPERATING_SYSTEM != "Darwin" ]; then
  exit 1
fi

# LOGGING VARIABLES
CNT="[\033[1;36mNOTE\033[0m]"
COK="[\033[1;32mOK\033[0m]"
CER="[\033[1;31mERROR\033[0m]"
CAT="[\033[1;37mATTENTION\033[0m]"
CWR="[\033[1;35mWARNING\033[0m]"
CAC="[\033[1;33mACTION\033[0m]"

# LOG SYSTEM INFORMATION
clear
echo "$CNT Operating System: $OPERATING_SYSTEM"
echo "$CNT Operating System Version: $(sw_vers -productVersion)"
echo "$CNT Kernel Version: $(uname -r)"
echo "$CNT Architecture: $(uname -m)"
echo "$CNT Hostname: $(hostname)"
echo "$CNT Username: $(whoami)"
echo "$CNT Home Directory: $HOME"

# ENSURE XCDOE COMMAND LINE TOOLS ARE INSTALLED
if ! xcode-select -p > /dev/null; then
  echo "$CAC Installing Xcode Command Line Tools"
  xcode-select --install > /dev/null
  if [ $? -ne 0 ]; then
    echo "$CER Xcode Command Line Tools could not be installed"
    exit 1
  fi
fi
echo "$COK Xcode Command Line Tools are installed"

# ENSURE XCODE COMMAND LINE TOOLS ARE UP TO DATE
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

# ENSURE HOMEBREW IS INSTALLED
if ! command -v brew > /dev/null; then
  echo "$CAC Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "$CER Homebrew could not be installed"
    exit 1
  fi
fi
echo "$COK Homebrew is installed"

# ENSURE HOMEBREW IS UP TO DATE
echo "$CAC Updating Homebrew"
brew update > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Homebrew could not be updated"
  exit 1
fi
echo "$COK Homebrew is up to date"

# ENSURE EXISTING HOMEBREW FORMULAE ARE UPGRADED
echo "$CAC Upgrading existing Homebrew formulae"
brew upgrade > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Existing Homebrew formulae could not be upgraded"
  exit 1
fi
echo "$COK Existing Homebrew formulae are up to date"

# ENSURE HOMEBREW IS READY TO BREW
echo "$CAC Checking Homebrew is ready to brew"
brew doctor > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Homebrew is not ready to brew"
  exit 1
fi
echo "$COK Homebrew is ready to brew"

# ENSURE CORE SOFTWARE IS INSTALLED
echo "$CAC Installing core software"
for i in "${CORE_SOFTWARE[@]}"; do
  if ! brew list $i > /dev/null; then
    echo "$CAC Installing $i"
    brew install $i > /dev/null
    if [ $? -ne 0 ]; then
      echo "$CER $i could not be installed"
      exit 1
    fi
  fi
done

# ENSURE WORKSTATION CORE SOFTWARE IS INSTALLED
echo "$CAC Installing workstation core software"
for i in "${WORKSTATION_CORE_SOFTWARE[@]}"; do
  if ! brew list $i > /dev/null; then
    echo "$CAC Installing $i"
    brew install $i > /dev/null
    if [ $? -ne 0 ]; then
      echo "$CER $i could not be installed"
      exit 1
    fi
  fi
done

# ENSURE WORKSTATION MACOS SOFTWARE IS INSTALLED
echo "$CAC Installing workstation MacOS software"
for i in "${WORKSTATION_MACOS_SOFTWARE[@]}"; do
  if ! brew list $i > /dev/null; then
    echo "$CAC Installing $i"
    brew install $i > /dev/null
    if [ $? -ne 0 ]; then
      echo "$CER $i could not be installed"
      exit 1
    fi
  fi
done

# STOW CORE CONFIGURATION FILES
echo "$CAC Stowing core configuration files"
stow -t $HOME core > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Core configuration files could not be stowed"
  exit 1
fi
echo "$COK Core configuration files have been stowed"

# STOW WORKSTATION CORE CONFIGURATION FILES
echo "$CAC Stowing workstation core configuration files"
stow -t $HOME workstation-core > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Workstation core configuration files could not be stowed"
  exit 1
fi
echo "$COK Workstation core configuration files have been stowed"

# STOW WORKSTATION MACOS CONFIGURATION FILES
echo "$CAC Stowing workstation MacOS configuration files"
stow -t $HOME workstation-macos > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Workstation MacOS configuration files could not be stowed"
  exit 1
fi
echo "$COK Workstation configuration files have been stowed"

# ENSURE OUTDATED HOMEBREW FORMULAE ARE CLEANED UP
echo "$CAC Cleaning up outdated Homebrew formulae"
brew cleanup > /dev/null
if [ $? -ne 0 ]; then
  echo "$CER Outdated Homebrew formulae could not be cleaned up"
  exit 1
fi
echo "$COK Outdated Homebrew formulae have been cleaned up"

# EXIT
echo "$COK Installation complete"
exit 0
