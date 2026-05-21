{
  lib,
  writeShellScriptBin,
  tmux,
}:

# Utility script to kill all tmux sessions
writeShellScriptBin "twx" ''
  export PATH=${lib.makeBinPath [ tmux ]}
  tmux kill-server
''
