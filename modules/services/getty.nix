{ lib, ... }:

let
  text = "Welcome Home";
in

{
  services.getty.helpLine = lib.mkDefault text;
  services.getty.greetingLine = lib.mkForce text;
}
