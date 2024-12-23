{ inputs, config, lib, ... }:

with lib;

{
  config = {
    users.users = {
      "dom.egginton" = {
        name = "dom.egginton";
        home = "/Users/dom.egginton";
      };
    };
  };
}
