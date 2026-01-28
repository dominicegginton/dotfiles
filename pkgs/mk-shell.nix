{
  lib,
  stdenv,
  makeSetupHook,
  writeScript,
  git,
}:

{
  name ? "nix-shell",
  packages ? [ ],
  inputsFrom ? [ ],
  ...
}@attrs:

let
  mergeInputs =
    name:
    (attrs.${name} or [ ])
    ++ (lib.subtractLists inputsFrom (lib.flatten (lib.catAttrs name inputsFrom)));
  rest = builtins.removeAttrs attrs [
    "name"
    "packages"
    "inputsFrom"
    "buildInputs"
    "nativeBuildInputs"
    "propagatedBuildInputs"
    "propagatedNativeBuildInputs"
    "shellHook"
  ];
in

stdenv.mkDerivation (
  {
    inherit name;
    buildInputs = mergeInputs "buildInputs";
    nativeBuildInputs =
      packages
      ++ (mergeInputs "nativeBuildInputs")
      ++ [
        (makeSetupHook { name = "set-shell-prompt"; } (
          writeScript "set-shell-promote" ''
            function parse_git_dirty {
              [[ $(${git}/bin/git status --porcelain 2> /dev/null) ]] && echo "*"
            }
            function parse_git_branch {
              ${git}/bin/git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
            }
            PS1="\[\e[1;31m\][${name}]\[\e[0m\] \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch) \[\e[1;35m\]$\[\e[0m\] "
          ''
        ))
      ];
    propagatedBuildInputs = mergeInputs "propagatedBuildInputs";
    propagatedNativeBuildInputs = mergeInputs "propagatedNativeBuildInputs";
    shellHook = lib.concatStringsSep "\n" (
      lib.catAttrs "shellHook" (lib.reverseList inputsFrom ++ [ attrs ])
    );
    phases = [ "buildPhase" ];
    preferLocalBuild = true;
    buildPhase = ''
      { export; } >> "$out"
    '';
  }
  // rest
)
