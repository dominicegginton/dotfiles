{
  inputs,
  pkgs,
  platform,
}: let
  packages = pkgs.${platform};
in
  pkgs.${platform}.mkShell rec {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with packages; [
      nodejs
      typescript
    ];
  }
