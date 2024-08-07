{ hostname, ... }:

{
  imports = [
    ./${hostname}
    ../../modules/darwin
  ];
}
