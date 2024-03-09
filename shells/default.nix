{
  inputs,
  pkgs,
  platform,
  ...
}: let
  # NIX_CONFIG.
  # Enable flakes and nix-command.
  NIX_CONFIG = "experimental-features = nix-command flakes";

  # Development packages.
  # List of packages that are useful for development.
  # Avaiable within all development shells in this workspace.
  developmentPkgs = with pkgs; [
    git # Version control system
    gitAndTools.git-crypt # Git extension to transparently encrypt/decrypt files in a git repository
    gitAndTools.git-lfs # Git extension for versioning large files
    gh # GitHub CLI tool
  ];

  # Python.
  # Generic Python development environment.
  python = import ./python.nix {inherit NIX_CONFIG pkgs developmentPkgs;};

  # Rust.
  # Generic Rust development environment.
  rust = import ./rust.nix {inherit NIX_CONFIG pkgs developmentPkgs;};

  # Web.
  # Generic Web development environment.
  web = import ./web.nix {inherit NIX_CONFIG pkgs developmentPkgs;};

  # Workspace.
  # Development shell for this workspace.
  workspace = import ./workspace.nix {inherit inputs NIX_CONFIG pkgs developmentPkgs platform;};
in {
  inherit python rust web workspace;

  # Set the default development shell to the workspace shell.
  default = workspace;
}
