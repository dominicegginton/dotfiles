{pkgs, ...}:
pkgs.writeShellApplication {
  name = "twx";

  runtimeInputs = with pkgs; [tmux];

  text = ''
    tmux kill-server
  '';
}
