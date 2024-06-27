{ pkgs }:

pkgs.writeShellApplication {
  name = "prune-docker";
  runtimeInputs = with pkgs; [ docker ];

  text = ''
    docker system prune -a
    docker volume prune --volumes
  '';
}
