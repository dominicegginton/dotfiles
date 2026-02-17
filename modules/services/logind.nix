{ ... }:

{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
}
