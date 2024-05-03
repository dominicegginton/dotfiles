{
  NIX_CONFIG,
  pkgs,
  developmentPkgs ? [],
}:
pkgs.mkShell rec {
  inherit NIX_CONFIG;
  nativeBuildInputs = with pkgs;
    [
      nodejs
      typescript
      nodePackages.typescript-language-server
      nodePackages.http-server
      nodePackages.prettier
      nodePackages.eslint
    ]
    ++ developmentPkgs;
}
