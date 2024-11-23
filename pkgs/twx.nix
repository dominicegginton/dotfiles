{ writeShellApplication, tmux }:

writeShellApplication {
  name = "twx";
  runtimeInputs = [ tmux ];
  text = "tmux kill-server";
}
