{
  writeShellScriptBin,
  sbomnix,
}:

# This function wraps a given Nix package with additional passthru utilities
# provided by sbomnix. These utilities allow for SBOM (Software Bill of Materials)
# generation, dependency graphing, provenance, and vulnerability scanning.
#
# Arguments:
#   pkg: The Nix package to be wrapped with sbomnix utilities.
#
# Usage:
#   with-sbomnix pkg
#
pkg:
# Override the package's attributes to add sbomnix-related passthru scripts
pkg.overrideAttrs (_: {
  # Adds a 'sbomnix' script to the package's passthru, which generates an SBOM for the package output
  passthru.sbomnix = writeShellScriptBin "sbomnix" ''
    ${sbomnix}/bin/sbomnix ${pkg.out} "$@"
  '';

  # Adds a 'nixgraph' script to the package's passthru, which generates a dependency graph for the package output
  passthru.nixgraph = writeShellScriptBin "nixgraph" ''
    ${sbomnix}/bin/nixgraph ${pkg.out} "$@"
  '';

  # Adds a 'provenance' script to the package's passthru, which outputs provenance information for the package output
  passthru.provenance = writeShellScriptBin "provenance" ''
    ${sbomnix}/bin/provenance ${pkg.out} "$@"
  '';

  # Adds a 'vulnxscan' script to the package's passthru, which scans the package output for known vulnerabilities
  passthru.vulnxscan = writeShellScriptBin "vulnxscan" ''
    ${sbomnix}/bin/vulnxscan ${pkg.out} "$@"
  '';
})
