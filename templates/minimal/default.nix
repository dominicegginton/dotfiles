{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "hello-world";

  text = ''
    echo "Hello, world!"
  '';
}
