let
  # This is the nixpkgs commit used by the branch aaronjanse/aj-redox
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/903a0cac04a10ca50ca461e2fad127d05b7f1419.tar.gz";
    sha256 = "1kb5h8dkkmz1a2hxncvr9k5ni79fasn6r8ny740vx6iyvpcxfnnq";
  };

  upstreamPkgs = import nixpkgs {};

  # This nixpkgs is then patched to support the redox target
  # Patches are comming from the branch aaronjanse/aj-redox
  nixpkgsPatched = upstreamPkgs.stdenv.mkDerivation {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = [ ./patches/0001-redox-add-as-target.patch ];
    installPhase = "cp -r ./ $out/";
    fixupPhase = ":";
  };
  overlay = import ./overlay;
  pkgs = import nixpkgsPatched {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
  };
in

pkgs.pkgsCross.x86_64-unknown-redox // {
  origPkgs = pkgs;
}
