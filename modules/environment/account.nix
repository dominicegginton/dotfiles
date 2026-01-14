{ lib, ... }:

{
  environment.etc."/default/useradd".text = lib.mkForce ''
    INACTIVE=35
  '';
}
