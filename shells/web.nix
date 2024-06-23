{ pkgs }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    typescript
    nodePackages.typescript-language-server
    nodePackages.http-server
    nodePackages.prettier
    nodePackages.eslint
  ];
}
