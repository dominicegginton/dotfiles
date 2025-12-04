{ lib, ... }:

{
  security.tpm2 = {
    enable = lib.mkDefault true; # tpm2 support
    pkcs11.enable = lib.mkDefault true; # pkcs11 support
  };
}


