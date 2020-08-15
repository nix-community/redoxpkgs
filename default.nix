let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/aaronjanse/nixpkgs/archive/aj-tmp.tar.gz";
    sha256 = "0licj27v0xb49f2y56q7bnyrlprlxckcnsgx9k459v6qdvkcdsjj";
  });
  overlay = import ./overlay;
in

with (nixpkgs {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
}); pkgs
