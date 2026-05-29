{
  config,
  lib,
  hostname,
  ...
}:

let
  cfg = config.services.residence.githubRunner;
in

{
  options.services.residence.githubRunner = {
    enable = lib.mkEnableOption "GitHub self-hosted runner";

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/dominicegginton/dotfiles";
      description = "Repository or organization URL where the runner should register.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.path;
      default = config.sops.secrets."services/github/runner-token".path;
      description = "Path to a token file (prefer PAT) used to register the runner.";
    };

    runnerName = lib.mkOption {
      type = lib.types.str;
      default = hostname;
      description = "Runner name shown in GitHub Actions.";
    };

    extraLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "nix"
        hostname
      ];
      description = "Additional labels for job routing.";
    };

    ephemeral = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run in ephemeral mode so each job uses a freshly registered runner.";
    };

    replace = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Replace an existing runner registration with the same name.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.github-runners.${cfg.runnerName} = {
      enable = true;
      url = cfg.url;
      tokenFile = cfg.tokenFile;
      name = cfg.runnerName;
      extraLabels = cfg.extraLabels;
      ephemeral = cfg.ephemeral;
      replace = cfg.replace;
    };
  };
}
