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

  constraints = import ./constraints.nix {};
in {
  inherit
    (helpers)
    forSystems
    mkNixosHost
    mkDarwinHost
    mkHome
    ;
  inherit constraints;
}
