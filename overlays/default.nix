{inputs}: {
  additions = final: _prev:
    (import ../pkgs {pkgs = final;})
    // {
      nsm = inputs.nsm.defaultPackage.${final.system};
      todo = inputs.todo.packages.${final.system}.todo;
    };
  modifications = _final: _prev: {};
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {inherit (final) system;};
  };
}
