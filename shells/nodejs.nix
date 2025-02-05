{ lib, mkShell, nodejs, nodePackages }:

mkShell {
  nativeBuildInputs = [
    (lib.development-promt "temp nodejs shell")
    nodejs
    lib.nodejs-setup-hook
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
  ];
}
