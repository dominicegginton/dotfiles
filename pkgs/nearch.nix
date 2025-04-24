{ lib, writeShellScriptBin, nix }:

writeShellScriptBin "nerch" ''
  export PATH=${lib.makeBinPath [ nix ]}
  nix search "$@"
''

