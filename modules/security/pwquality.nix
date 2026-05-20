{ lib, ... }:

{
  # TODO: remove one applies by dit0
  # Configure password quality requirements for PAM.
  # - ucredit: require at least one uppercase character
  # - lcredit: require at least one lowercase character
  # - dcredit: require at least one digit
  # - ocredit: require at least one special character
  # - difok: require at least 8 different characters from the old password
  # - minlen: require a minimum length of 15 characters
  # - dictcheck: enable dictionary checks to prevent common passwords from being used
  environment.etc."/security/pwquality.conf".text = lib.mkDefault ''
    ucredit=-1
    lcredit=-1
    dcredit=-1
    difok=8
    minlen=15
    ocredit=-1
    dictcheck=1
  '';
}
