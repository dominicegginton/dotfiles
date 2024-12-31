{ config, ... }:

{
  config = {
    console.enable = true;
    console.earlySetup = true;
    console.keyMap = "uk";
    console.colors = config.scheme.toList;
  };
}
