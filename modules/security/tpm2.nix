{ lib, ... }:

{
  # Enable TPM 2.0 support for enhanced hardware based security features
  security.tpm2 = {
    enable = lib.mkDefault true;

    # Configure PKCS#11 support for TPM 2.0
    pkcs11.enable = lib.mkDefault true;
  };
}
