{ lib, ... }:

{
  security.tpm2 = {
    enable = lib.mkDefault true;
    pkcs11.enable = lib.mkDefault true;
  };
}


