{ dockerTools, hello-world }:

dockerTools.buildLayeredImage {
  inherit (hello-world) name;
  tag = "latest";
  created = "now";
  contents = [ hello-world ];
  config.Cmd = hello-world.pname;
  config.ExposedPorts = { "8000" = { }; };
}
