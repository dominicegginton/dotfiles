{pkgs, ...}: {
  imports = [
    ../dom
    ../dom/sources
  ];

  home.packages = with pkgs; [
    timewarrior
    taskwarrior
  ];
}
