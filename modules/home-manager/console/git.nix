{ pkgs, ... }:

{
  config = {
    programs = {
      git.enable = true;
      gh = {
        enable = true;
        extensions = with pkgs; [ gh-markdown-preview ];
        settings = {
          editor = "nvim";
          git_protocol = "https";
          prompt = "enabled";
        };
      };
    };

    home.packages = with pkgs; [ gitu ];
  };
}
