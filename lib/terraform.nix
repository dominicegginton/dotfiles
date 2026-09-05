# lib/terraform.nix
#
# Custom Terraform helpers for declarative, reproducible builds
# of Terraform configurations under Nix.

{ pkgs }:

let
  inherit (pkgs)
    lib
    stdenv
    jq
    makeWrapper
    symlinkJoin
    coreutils
    terraform
    ;
in

rec {
  # Standardized set of Terraform provider plugins used in this repository
  defaultProviders = [
    "hashicorp_google"
    "hashicorp_local"
    "hashicorp_random"
    "tailscale_tailscale"
    "cloudflare_cloudflare"
  ];

  # Wrapper package containing Terraform preconfigured with all default provider plugins.
  # Can be parameterized with custom paths and validation options.
  terraformWithPlugins =
    {
      paths ? [ ],
      validate ? false,
    }:
    mkTerraformDerivation {
      name = "personal-infra";
      package = terraform;
      providers = defaultProviders;
      inherit paths validate;
    };

  # Create a versions.tf.json file and lock file for given terraform package and list of provider names.
  writeTerraformVersions =
    {
      package,
      providers ? [ ],
      writeRequiredProviders ? false,
    }:

    let
      filename = "versions.tf.json";

      packageWithProviders =
        if providers != [ ] then
          package.withPlugins (p: map (name: if builtins.isString name then p.${name} else name) providers)
        else
          package;

      mainProgram = package.meta.mainProgram or "terraform";
      version = lib.pipe package [
        lib.getVersion
        (lib.splitString "-")
        builtins.head
      ];

      useDependencyLockfile =
        writeRequiredProviders && providers != [ ] && lib.versionAtLeast version "0.14.0";

      config = {
        terraform = {
          required_version = version;
        }
        // lib.optionalAttrs (writeRequiredProviders && providers != [ ]) {
          required_providers = lib.listToAttrs (
            map (
              name:
              let
                provider = package.plugins.${name};
                localName = lib.last (lib.splitString "/" provider.provider-source-address);
              in
              {
                name = localName;
                value = {
                  version = lib.getVersion provider;
                  source = provider.provider-source-address;
                };
              }
            ) providers
          );
        };
      };
    in

    stdenv.mkDerivation {
      name = "versions-tf";
      dontUnpack = true;
      value = builtins.toJSON config;
      passAsFile = [ "value" ];

      nativeBuildInputs = [ jq ] ++ lib.optional useDependencyLockfile packageWithProviders;
      buildPhase = ''
        jq . "$valuePath" > ${filename}

        ${lib.optionalString useDependencyLockfile ''
          export HOME=$TMPDIR
          ${mainProgram} init -backend=false -plugin-dir=${packageWithProviders}/libexec/terraform-providers
        ''}
      '';

      installPhase = ''
        mkdir -p $out
        cp ${filename} $out
        ${lib.optionalString useDependencyLockfile ''
          cp .terraform.lock.hcl $out
        ''}
      '';

      passthru = {
        inherit config;
      };
    };

  # Create a derivation of a terraform root module directory for a terraform package and list of provider names.
  mkTerraformDerivation =
    {
      name,
      package,
      providers ? [ ],
      paths ? [ ],
      validate ? true,
      preCommand ? "",
      ...
    }:

    let
      mainProgram = package.meta.mainProgram or "terraform";
      packageWithProviders =
        if providers != [ ] then
          package.withPlugins (p: map (name: if builtins.isString name then p.${name} else name) providers)
        else
          package;
    in

    symlinkJoin {
      name = "${name}-tf";
      inherit paths;

      postBuild =
        let
          makeWrapperArgs = lib.strings.escapeShellArgs (
            [
              "--run"
              ''
                if [ -n "''${TRACE:-}" ]; then
                  set -o xtrace
                  export TF_LOG=1
                fi
              ''
              "--run"
              ''dir="''${TF_ROOT_DIR:-$PWD}"''
              "--run"
              ''export TF_DATA_DIR="''${TF_DATA_DIR:-''${TMPDIR:-/tmp}/.terraform-''${dir##*/}}"''
            ]
            ++ lib.optionals (preCommand != "") [
              "--run"
              preCommand
            ]
            ++ (
              if lib.versionAtLeast (lib.getVersion package) "0.15.0" && providers != [ ] then
                [
                  "--prefix"
                  "TF_CLI_ARGS_init"
                  " "
                  "-plugin-dir=${packageWithProviders}/libexec/terraform-providers"
                ]
              else if !(lib.versionAtLeast (lib.getVersion package) "0.15.0") then
                [
                  "--run"
                  ''cd "$dir"''
                ]
              else
                [ ]
            )
          );
        in
        ''
          makeWrapper ${packageWithProviders}/bin/${mainProgram} $out/bin/${mainProgram} ${makeWrapperArgs}

          ${lib.optionalString validate ''
            $out/bin/${mainProgram} init -backend=false
            $out/bin/${mainProgram} validate
          ''}
        '';

      nativeBuildInputs = [ makeWrapper ];

      meta = {
        inherit mainProgram;
      };
    };
}
