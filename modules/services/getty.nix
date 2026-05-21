{ lib, ... }:

let
  text = "Welcome Home";
in

{
  # Custom TTY login greeting
  services.getty.helpLine = lib.mkDefault text;
  services.getty.greetingLine = lib.mkForce text;
}
