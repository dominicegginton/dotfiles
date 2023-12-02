{pkgs, ...}:
pkgs.writeShellApplication {
  name = "rebuild-configuration";

  runtimeInputs = with pkgs; [
    workspace.rebuild-host
    workspace.rebuild-home
  ];

  text = ''
    rebuild-host
    rebuild-home
  '';
}
