{
  self,
  config,
  lib,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = lib.mkForce true; # Always use global pkgs for Home Manager
    backupFileExtension = lib.mkForce "backup"; # Set backup extension for Home Manager
    sharedModules = [
      self.inputs.base16.homeManagerModule # Base16 theming for Home Manager
      {
        scheme = config.scheme;
        home = {
          stateVersion = lib.mkForce "25.11"; # Pin Home Manager state version
          enableNixpkgsReleaseCheck = lib.mkForce false; # Disable release check
        };
        programs = {
          bash.enable = lib.mkForce true; # Always enable bash
          info.enable = lib.mkForce true; # Always enable info
          hstr.enable = lib.mkForce true; # Always enable hstr
        };
      }
    ];
  };
}
