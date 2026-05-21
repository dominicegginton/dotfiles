{ lib, ... }:

{
  # Password quality requirements for PAM
  # - ucredit: At least one uppercase character
  # - lcredit: At least one lowercase character
  # - dcredit: At least one digit
  # - ocredit: At least one special character
  # - difok: At least 8 different characters from old password
  # - minlen: Minimum length of 15 characters
  # - dictcheck: Prevent common dictionary words
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
