{ vscode-with-extensions, vscode-extensions }:

let
  defaultExtensions = with vscode-extensions; [ bbenoist.nix vscodevim.vim github.copilot github.github-vscode-theme ];
in

(vscode-with-extensions.override { vscodeExtensions = defaultExtensions; }) //

{ override = args: vscode-with-extensions.override (args // { vscodeExtensions = defaultExtensions ++ (args.vscodeExtensions or [ ]); }); }
