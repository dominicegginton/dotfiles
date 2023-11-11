{
  inputs,
  outputs,
  stateVersion,
  ...
}: let
  helpers = import ./helpers.nix {inherit inputs outputs stateVersion;};
in {
  inherit (helpers) mkNixosConfiguration;
  inherit (helpers) mkDarwinConfiguration;
  inherit (helpers) mkHomeConfiguration;
  inherit (helpers) forAllSystems;
}
