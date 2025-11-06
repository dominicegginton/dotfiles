{ pkgs, ... }:
{

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268124
  services.sssd.enable = true;
  environment.etc."sssd/pki/sssd_auth_ca_db.pem".source =
    let
      certzip = pkgs.fetchzip {
        url = "https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/unclass-certificates_pkcs7_v5-6_dod.zip";
        sha256 = "sha256-iwwJRXCnONk/LFddQlwy8KX9e9kVXW/QWDnX5qZFZJc=";
      };
    in
    "${certzip}/DoD_PKE_CA_chain.pem";

  # https://stigui.com/stigs/Anduril_NixOS_STIG/groups/V-268178
  services.sssd.config = ''
    [pam]
    offline_credentials_expiration = 1
  '';

}
