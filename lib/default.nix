{
  inputs,
  outputs,
  stateVersion,
  ...
}: let
  helpers = import ./helpers.nix {
    inherit
      inputs
      outputs
      stateVersion
      ;
  };
in {
  inherit
    (helpers)
    forSystems
    mkNixosHost
    mkDarwinHost
    mkHome
    ;
}
