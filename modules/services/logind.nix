{ lib, ... }:

{
  services.logind.settings.Login = {
    HandleLidSwitch = lib.mkDefault "suspend";
    HandleLidSwitchDocked = lib.mkDefault "ignore";
  };
}
