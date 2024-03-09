{
  NIX_CONFIG,
  pkgs,
  developmentPkgs ? [],
}:
pkgs.mkShell rec {
  inherit NIX_CONFIG;

  nativeBuildInputs = with pkgs; [
      nodejs # NodeJS runtime and NPM package manager
      typescript # TypeScript compiler
      nodePackages.typescript-language-server # TypeScript language server
      nodePackages.http-server # Simple HTTP server
      nodePackages.prettier # Code formatter
      nodePackages.eslint # Linter for JavaScript
    ]
    ++ developmentPkgs;
}
