#/usr/local/env sh

install_cargo_package () {
  cargo install $1
}

install_cargo_packages () {
  filename=~/.local/utils/cargo-packages
  if [ -f $filename ]; then
    while read -r line; do
      install_cargo_package $line
    done < $filename
  fi
}

update_cargo_packages () {
  cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')
}
