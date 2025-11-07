{ pkgs, config, lib, ... }:

let

  vscodeConfig = pkgs.writeText "config.json" ''
    {
      "extensions.autoUpdate": true,
      "update.mode": "default",
      "telemetry.enableTelemetry": false,
      "telemetry.enableCrashReporter": false
    }
  '';

in

{
  options.programs.vscode.enable = lib.mkEnableOption "VSCode";

  config = lib.mkIf config.programs.vscode.enable {
    environment.systemPackages = [

      (pkgs.symlinkJoin {
        name = "vscode";
        paths = [ pkgs.vscode ];

        buildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/code --append-flags "--config ${vscodeConfig}"
        '';
      })
    ];
  };
}

