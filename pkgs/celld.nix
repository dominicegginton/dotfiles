{ lib
, stdenv
, fetchurl
, makeWrapper
, esbuild
, zlib
, autoPatchelfHook ? null
,
}:

let
  version = "0.6.2";

  sources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      sha256 = "ce0ee3552cc8d55dde3998dc3b1b0c8f547bbcb4bc803d2a94842368b047646c";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      sha256 = "4eca87c6797590000a344c1b768364e9696e8817f5fbc16193f459d2edac7cd0";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      sha256 = "b81a38299800679e9651fd7c1544540185682dcb59eed1a24c8cc36c6b31e76d";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system for celld: ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation {
  pname = "celld";
  inherit version;

  src = fetchurl {
    url = "https://github.com/denoland/celld/releases/download/v${version}/celld-${source.target}.gz";
    inherit (source) sha256;
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && autoPatchelfHook != null) [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc "$src" > "$out/bin/celld"
    chmod +x "$out/bin/celld"
    wrapProgram "$out/bin/celld" \
      --prefix PATH : ${lib.makeBinPath [ esbuild ]} \
      --set-default CELLD_ESBUILD ${lib.getExe esbuild}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Self-hosted, distributed Durable Objects daemon";
    longDescription = ''
      celld is an open-source daemon that runs a Cloudflare Workers application on
      your own machines: Workers, Durable Objects, KV, Queues, D1, R2, Workflows,
      Cron Triggers, and static assets, deployed from the wrangler.json that you already have.
    '';
    homepage = "https://celld.dev";
    changelog = "https://github.com/denoland/celld/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ dominicegginton ];
    platforms = builtins.attrNames sources;
    mainProgram = "celld";
  };
}
