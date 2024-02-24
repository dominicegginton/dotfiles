{pkgs, ...}:
pkgs.writeShellApplication {
  name = "rebuild-configuration";

  runtimeInputs = with pkgs; [
    rebuild-host
    rebuild-home
  ];

  text = ''
    rebuild-host
    rebuild-home
  '';
}
