{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    python39
    python39Packages.pip
    python39Packages.virtualenv
  ];

  shellHook = ''
    if [ ! -d .venv ]; then
      echo "No virtual environment found."
      read -p "Would you like to create a virtual environment? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        python3.9 -m venv .venv
      fi
    fi
    if [ -d .venv ]; then
      echo "Activating virtual environment."
      source .venv/bin/activate
    fi
  '';
}
