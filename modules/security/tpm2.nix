{ lib, ... }:

{
  security.tpm2 = {
    enable = lib.mkDefault true; # tpm2 support
    pkcs11.enable = lib.mkDefault true; # pkcs11 support
    abrmd.enable = lib.mkDefault true;
    tctiEnvironment.enable = lib.mkDefault true;
  };
}


