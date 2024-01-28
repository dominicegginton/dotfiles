{pkgs, ...}:
pkgs.writeShellApplication {
  name = "workspace-formatter";

  runtimeInputs = with pkgs; [
    alejandra
    nodePackages.prettier
  ];

  text = ''
    alejandra .
    prettier --write README.md
  '';
}
