{ inputs, outputs, stateVersion, darwinStateVersion, ... }:

let
  helpers = import ./helpers.nix { inherit inputs outputs stateVersion darwinStateVersion; };
in

{
  inherit (helpers) mkHome;
  inherit (helpers) mkHost;
  inherit (helpers) mkDarwinHost;
  inherit (helpers) forAllSystems;
}
