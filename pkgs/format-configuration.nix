{pkgs, ...}:
pkgs.writeShellApplication {
  name = "format-configuration";

  runtimeInputs = with pkgs; [
    alejandra
    nodePackages.prettier
  ];

  text = ''
    alejandra ./
    prettier --write README.md
  '';
}
