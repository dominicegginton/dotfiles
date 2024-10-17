{ pkgs, lib, dockerTools, writeShellApplication }:

rec {
  pkg = pkgs.python3Packages.buildPythonApplication {
    pname = "hello-world";
    version = "0.0.0";
    propagatedBuildInputs = with pkgs.python3Packages; [ fastapi uvicorn ];
    src = lib.sources.cleanSource ./.;
  };

  oci = dockerTools.buildLayeredImage {
    name = pkg.name;
    tag = "latest";
    created = "now";
    contents = [ pkg ];
    config.Cmd = pkg.pname;
    config.ExposedPorts = { "8000" = { }; };
  };

  deploy = writeShellApplication {
    name = "deploy-${pkg.pname}";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      docker load -i ${oci}
      docker run --net=host ${oci.imageName}:${oci.imageTag}
    '';
  };
}
