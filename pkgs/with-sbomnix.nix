{ writeShellScriptBin, sbomnix }:


pkg: pkg.overrideAttrs (_: {
  passthru.sbomnix = writeShellScriptBin "sbomnix" ''
    ${sbomnix}/bin/sbomnix ${pkg.out} "$@"
  '';

  passthru.nixgraph = writeShellScriptBin "nixgraph" ''
    ${sbomnix}/bin/nixgraph ${pkg.out} "$@"
  '';

  passthru.provenance = writeShellScriptBin "provenance" ''
    ${sbomnix}/bin/provenance ${pkg.out} "$@"
  '';

  passthru.vulnxscan = writeShellScriptBin "vulnxscan" ''
    ${sbomnix}/bin/vulnxscan ${pkg.out} "$@"
  '';
})
