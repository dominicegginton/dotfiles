{ ... }:

{
  networking.wireless = {
    enable = true;
    userControlled = {
      enable = true;
      group = "wheel";
    };
  };
}
