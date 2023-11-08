{pkgs, ...}: {
  programs.gh = {
    enable = true;
    extensions = with pkgs; [
      gh-markdown-preview
    ];
    settings = {
      editor = "nvim";
      git_protocol = "https";
      prompt = "enabled";
    };
  };
}
