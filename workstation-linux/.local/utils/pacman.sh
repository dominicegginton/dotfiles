#/usr/local/env sh

install_pacman_package () {
  sudo pacman -S $1
}

install_pacman_packages () {
  filename=~/.local/utils/pacman-packages
  packages=''
  if [ -f $filename ]; then
    packages=$(cat $filename)
    install_pacman_package $packages
  fi
}
