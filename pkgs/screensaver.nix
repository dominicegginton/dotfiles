{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "screensaver";

  runtimeInputs = with pkgs; [mpvpaper yt-dlp];

  text = ''
    ${pkgs.mpvpaper}/bin/mpvpaper --fork -o 'no-audio loop script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp' -l background '*' 'https://www.youtube.com/watch?v=wLd3dfix2B8'

    # ${pkgs.swayidle}/bin/swayidle -w \
    #   timeout 5 "${pkgs.mpvpaper}/bin/mpvpaper --fork -o 'no-audio loop script-opts=ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp' -l top '*' https://www.youtube.com/watch?v=X8x_DFFOglg&list=PLozotZAwoq6CeyZE9twZAxst6QGbaHnDb" \
    #   resume "${pkgs.killall}/bin/killall mpvpaper" \
    #   before-sleep "${pkgs.killall}/bin/killall mpvpaper"
  '';
}
