{ vscode-with-extensions, vscode-extensions }:

let
  extensions = with vscode-extensions; [
    vscodevim.vim
    github.github-vscode-theme
    github.vscode-pull-request-github
    github.vscode-github-actions
    github.copilot
    ms-azuretools.vscode-docker
    bbenoist.nix
    sumneko.lua
    ms-python.python
    tekumara.typos-vscode
  ];
in

(vscode-with-extensions.override { vscodeExtensions = extensions; }) //

{ override = args: vscode-with-extensions.override (args // { vscodeExtensions = extensions ++ (args.vscodeExtensions or [ ]); }); }
