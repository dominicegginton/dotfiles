{pkgs}:
pkgs.writeShellApplication rec {
  name = "twx";
  runtimeInputs = with pkgs; [tmux];
  text = ''
    echo "Killing tmux server..."
    tmux kill-server
  '';
}
