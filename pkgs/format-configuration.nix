{pkgs, ...}:
pkgs.writeShellApplication {
  name = "format-configuration";

  runtimeInputs = with pkgs; [
    alejandra
    nodePackages.prettier
  ];

  text = ''
    pushd ~/.dotfiles
    alejandra ./
    prettier --write README.md
  '';
}
