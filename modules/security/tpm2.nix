{ lib, ... }:

{
  security.tpm2 = {
    enable = lib.mkDefault true; # Enable TPM 2.0 support
    pkcs11.enable = lib.mkDefault true; # Enable PKCS#11
  };
}
