{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.wsl.wrappedShell;
in

{
  options.wsl.wrappedShell = {
    enable = lib.mkEnableOption "wrapping /bin/bash with WSL shell wrapper";
  };

  config = lib.mkMerge [
    {
      wsl.wrappedShell.enable = lib.mkDefault config.wsl.enable;
    }

    (lib.mkIf (config.wsl.enable && cfg.enable) {
      # Wrap /bin/bash with WSL shell wrapper so non-interactive bash invocations
      # (e.g. VS Code / Cursor remote server installer scripts) have PATH populated.
      wsl.extraBin =
        let
          wrapShell =
            shellPath:
            pkgs.stdenvNoCC.mkDerivation {
              name = "wrapped-${lib.last (lib.splitString "/" shellPath)}";
              buildCommand = ''
                mkdir -p $out
                cp ${config.system.build.nativeUtils}/bin/shell-wrapper $out/wrapper
                ln -s ${shellPath} $out/shell
              '';
            };
        in
        [
          {
            src = "${wrapShell "${pkgs.bashInteractive}/bin/bash"}/wrapper";
            name = "bash";
          }
        ];
    })
  ];
}
