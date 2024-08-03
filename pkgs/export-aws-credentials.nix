{ pkgs, writeShellApplication }:

writeShellApplication {
  name = "export-aws-credentials";
  runtimeInputs = with pkgs; [ fzf awscli2 ];

  text = ''
    profile=$(aws configure list-profiles | fzf)
    if [ -z "$profile" ]; then
      echo "No profile selected"
      exit 1
    fi
    eval "$(aws configure export-credentials --profile "$profile" --format env)"
  '';
}
