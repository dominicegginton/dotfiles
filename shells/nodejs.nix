{ mkShell, nodejs, source-nodejs-packages-shell-hook, nodePackages }:

mkShell {
  packages = [
    nodejs
    source-nodejs-packages-shell-hook
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
  ];
}
