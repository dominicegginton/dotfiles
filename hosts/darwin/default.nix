{ hostname
, platform
, stateVersion
, pkgs
, ...
}:

{
  imports = [
    ./${hostname}
    ../../modules/darwin
  ];
}
