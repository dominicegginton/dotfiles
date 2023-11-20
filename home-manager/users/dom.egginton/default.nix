{pkgs, ...}: {
  imports = [
    ../dom
    ../dom/sources
  ];

  home.file.".timewarrior/timewarrior.cfg".text = ''
    verbose = yes
  '';

  home.packages = with pkgs; [
    timewarrior
    taskwarrior
  ];
}
