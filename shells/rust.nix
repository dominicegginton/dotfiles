{
  NIX_CONFIG,
  pkgs,
  developmentPkgs ? [],
}:
pkgs.mkShell rec {
  inherit NIX_CONFIG;

  nativeBuildInputs = with pkgs;
    [
      rustc # Rust compiler
      cargo # Rust package manager
    ]
    ++ developmentPkgs;
}
