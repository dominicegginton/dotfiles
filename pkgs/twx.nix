{ lib, writeShellScriptBin, tmux }:

writeShellScriptBin "twx" ''
  export PATH=${lib.makeBinPath [ tmux ]}
  tmux kill-server
''
