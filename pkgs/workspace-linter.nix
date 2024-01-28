{pkgs, ...}:
pkgs.writeShellApplication {
  name = "workspace-linter";

  runtimeInputs = with pkgs; [
    alejandra
    nodePackages.prettier
  ];

  text = ''
    alejandra --check .
    prettier --check README.md
  '';
}
