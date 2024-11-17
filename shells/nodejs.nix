{ mkShell, nodejs, nodejs-shell-setup-hook }:

mkShell {
  nativeBuildInputs = [ nodejs nodejs-shell-setup-hook ];
}
