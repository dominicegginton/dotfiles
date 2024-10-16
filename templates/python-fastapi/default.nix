{ pkgs, lib, dockerTools }:

rec {
  pkg = pkgs.python3Packages.buildPythonApplication {
    pname = "hello-world";
    version = "0.0.0";
    propagatedBuildInputs = with pkgs.python3Packages; [ fastapi uvicorn ];
    src = lib.sources.cleanSource ./.;
  };

  oci= dockerTools.buildLayeredImage {
    name = pkg.name;
    tag = "latest";
    contents = [ pkg ];
    config.Cmd = pkg.pname;
  };
}
