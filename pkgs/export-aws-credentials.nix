{ pkgs, writers }:

writers.writeBashBin "export-aws-credientials" ''
  profile=$(${pkgs.awscli2}/bin/aws configure list-profiles | ${pkgs.fzf}/bin/fzf)
  ${pkgs.awscli2}/bin/aws sso login --profile $profile
  eval $(${pkgs.awscli2}/bin/aws sso env --profile $profile --shell env)"
''
