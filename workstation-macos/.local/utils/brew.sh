#/usr/bin/env sh

install_brew_package () {
  brew install $1
}

install_brew_packages () {
  filename=~/.local/utils/brew-packages
  packages=''
  if [ -f $filename ]; then
    packages=$(cat $filename)
    install_brew_package $packages
  fi
}

update_brew_packages () {
  brew update
  brew outdated --greedy
  brew upgrade --greedy
  brew cleanup
}
