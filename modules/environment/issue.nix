{ lib, ... }:

{

  # set system issue file text - shown on tty login prompts
  config.environment.etc.issue.text = lib.mkForce "Residence";
}
