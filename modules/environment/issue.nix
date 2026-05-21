{ lib, ... }:

{
  # Set system issue file text - shown on TTY login prompts
  config.environment.etc.issue.text = lib.mkForce "Residence";
}
