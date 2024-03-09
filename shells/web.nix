{
  inputs,
  pkgs,
  developmentPkgs ? [],
}:
pkgs.mkShell rec {
  NIX_CONFIG = "experimental-features = nix-command flakes";

  nativeBuildInputs = with pkgs;
    [
      nodejs # NodeJS runtime and NPM package manager
      typescript # TypeScript compiler
      nodePackages.typescript-language-server # TypeScript language server
      nodePackages.http-server # Simple HTTP server
      nodePackages.prettier # Code formatter
      nodePackages.eslint # Linter for JavaScript
    ]
    ++ developmentPkgs;
}
