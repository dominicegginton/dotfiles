{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    defaultKeymap = "viins";

    initExtra = ''
      path=("$HOME/.cargo/bin" $path)
      path+=("$HOME/.local/bin")

      PROMPT=$'\n'"%F{6}%~%f"$'\n'"%B%(#.%F{1}.%F{2})%# %f%b"
    '';
  };
}
