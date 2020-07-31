let
  nixpkgs = import (fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "5c56778efdcaa1b8088eb536c3f1e9cc110930dc";
  });
  overlay = import ./overlay;
in

with (nixpkgs {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
}); pkgsCross.x86_64-unknown-redox // {
  origPkgs = pkgs;
}
