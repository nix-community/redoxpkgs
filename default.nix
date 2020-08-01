let
  nixpkgs = import (fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "64a9b4b7a341c7f423932bf8f4366f07654060e6";
  });
  overlay = import ./overlay;
in

with (nixpkgs {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
}); pkgsCross.x86_64-unknown-redox // {
  origPkgs = pkgs;
}
