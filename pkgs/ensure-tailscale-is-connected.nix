{
  lib,
  writeShellScriptBin,
  tailscale,
  jq,
  gum,
}:

writeShellScriptBin "ensure-tailscale-is-connected" ''
  export PATH=${
    lib.makeBinPath [
      tailscale
      jq
      gum
    ]
  };
  if ! $(tailscale status --json | jq -e '.Self.Online | . == true' >/dev/null); then
    gum log --level error "Not connected to Tailscale network"
    exit 1
  fi
''
