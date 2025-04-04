{ vscode-with-extensions, vscode-extensions }:

vscode-with-extensions

  //

{
  override = { vscodeExtensions ? [ ], ... } @args: vscode-with-extensions.override (args // {
    vscodeExtensions = with vscode-extensions; [
      bbenoist.nix
      vscodevim.vim
      github.copilot
      github.github-vscode-theme
    ] ++ vscodeExtensions;
  });
}
