{ writers, awscli2, fzf }:

writers.writeBashBin "export-aws-credientials" ''
  profile=$(${awscli2}/bin/aws configure list-profiles | ${fzf}/bin/fzf)
  ${awscli2}/bin/aws sso login --profile $profile
  eval $(${awscli2}/bin/aws sso env --profile $profile --shell env)"
''
