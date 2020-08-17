let
  nixpkgs = fetchTarball {
    url = "https://github.com/aaronjanse/nixpkgs/archive/aj-tmp.tar.gz";
    sha256 = "1hq5nqg63bc8v49aj4gp6wkn0saynrswc3fr6m66v5fvdxlp5nsd";
  };
  overlay = import ./overlay nixpkgs;
in
with (import nixpkgs {
  overlays = [ overlay ];
  config.allowUnsupportedSystem = true;
}); pkgs
