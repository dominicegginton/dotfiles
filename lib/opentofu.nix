# lib/opentofu.nix
#
# Custom OpenTofu helpers for declarative, reproducible builds
# of OpenTofu configurations under Nix.

{ pkgs }:

let
  inherit (pkgs)
    lib
    stdenv
    jq
    makeWrapper
    symlinkJoin
    opentofu
    ;
in

rec {
  # Wrapper package containing OpenTofu preconfigured with provider plugins.
  # Can be parameterized with custom providers, paths, and validation options.
  opentofuWithPlugins =
    {
      providers ? [ ],
      paths ? [ ],
      validate ? false,
    }:
    mkOpenTofuDerivation {
      name = "personal-infra";
      package = opentofu;
      inherit providers paths validate;
    };

  # Backwards-compatible alias
  terraformWithPlugins = opentofuWithPlugins;

  # Create a versions.tf.json file and lock file for given opentofu package and list of provider names.
  writeOpenTofuVersions =
    {
      package ? opentofu,
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

      mainProgram = package.meta.mainProgram or "tofu";
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

  writeTerraformVersions = writeOpenTofuVersions;

  # Create a derivation of an opentofu root module directory for an opentofu package and list of provider names.
  mkOpenTofuDerivation =
    {
      name,
      package ? opentofu,
      providers ? [ ],
      paths ? [ ],
      validate ? true,
      preCommand ? "",
      ...
    }:

    let
      mainProgram = package.meta.mainProgram or "tofu";
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
        description = "OpenTofu derivation for ${name} with providers: ${lib.concatStringsSep ", " providers}";
      };
    };

  mkTerraformDerivation = mkOpenTofuDerivation;
}
