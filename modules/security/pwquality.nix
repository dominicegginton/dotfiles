{ lib, ... }:

{
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
