{ lib, writeShellScriptBin, nix }:

writeShellScriptBin "nun" ''
  export PATH=${lib.makeBinPath [ nix ]}
  nix run "$@"
''
