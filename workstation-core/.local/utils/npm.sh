#/usr/local/env sh

install_npm_package () {
  sudo npm install -g $1
}

install_npm_packages () {
  filename=~/.local/utils/npm-packages
  packages=''
  if [ -f $filename ]; then
    packages=$(cat $filename)
    install_npm_package $packages
  fi
}

update_npm_packages () {
  sudo npm update -g
}
