{ lib
, buildNpmPackage
, makeWrapper
, nodejs_24
, python3
,
}:

buildNpmPackage {
  pname = "automerge-todo-list";
  version = "0.1.0";

  src = ./.;
  nodejs = nodejs_24;
  npmDepsHash = "sha256-9FlREoFar7KV5Vbv//NW3emk7XIjOcOjbthiqzULtls=";

  nativeBuildInputs = [ makeWrapper ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    npm test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --ignore-scripts --offline
    mkdir -p "$out/bin" "$out/lib/node_modules" "$out/share/automerge-todo-list"
    cp -r dist/. "$out/share/automerge-todo-list/"
    cp -r node_modules/. "$out/lib/node_modules/"

    makeWrapper ${python3}/bin/python "$out/bin/automerge-todo" \
      --add-flags "-m http.server 4173 --directory $out/share/automerge-todo-list"
    makeWrapper ${nodejs_24}/bin/node "$out/bin/automerge-todo-sync" \
      --add-flags "$out/lib/node_modules/@automerge/automerge-repo-sync-server/src/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Minimal Automerge-backed shared to-do list";
    homepage = "https://automerge.org/docs/reference/the-js-packages/";
    license = lib.licenses.mit;
    mainProgram = "automerge-todo";
    platforms = lib.platforms.linux;
  };
}
