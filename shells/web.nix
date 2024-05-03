{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell rec {
  nativeBuildInputs = with pkgs; [
    nodejs
    typescript
    nodePackages.typescript-language-server
    nodePackages.http-server
    nodePackages.prettier
    nodePackages.eslint
  ];
}
