let
  bootstrapNixpkgs = import <nixpkgs> {};
  nixpkgs = import (bootstrapNixpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "5c56778efdcaa1b8088eb536c3f1e9cc110930dc";
    sha256 = "0j6yhlnvshj24zk6liszwisfnc4cplhsibb7hwg18f5wmaj4alc9";
  });
  overlay = import ./overlay;
in

with (nixpkgs {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
}); pkgsCross.x86_64-unknown-redox // {
  origPkgs = pkgs;
}
