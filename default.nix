let
  parentNixpkgs = import (fetchGit {
    url = "https://github.com/aaronjanse/nixpkgs";
    ref = "aj-redox";
  });
  # parentNixpkgs = import ../rixpkgs;
  overlay = import ./overlay;
in

with (parentNixpkgs {
  overlays = [ overlay ];
  crossSystem = { config = "x86_64-unknown-redox"; };
  config.allowUnsupportedSystem = true;
}); pkgs
