{
  inputs,
  pkgs,
  baseDevPkgs,
  platform,
}:
pkgs.mkShell rec {
  NIX_CONFIG = "experimental-features = nix-command flakes";
  nativeBuildInputs = with pkgs;
    baseDevPkgs
    ++ [
      nodejs
      typescript
      nodePackages.ts-node
      nodePackages.typescript-language-server
      nodePackages.http-server
      nodePackages.prettier
      nodePackages.eslint
    ];
}
