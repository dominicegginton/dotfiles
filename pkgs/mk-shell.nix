{ mkShell, set-prompt-shell-hook }:

{ inputsFrom ? null, name ? if inputsFrom != null then (builtins.concatStringsSep " " (builtins.map (pkg: pkg.name) inputsFrom)) else "ad-hoc", ... } @args:

mkShell (args // { nativeBuildInputs = [ (set-prompt-shell-hook name) ] ++ (args.nativeBuildInputs or [ ]); })
