let
  pkgs = import ../default.nix;
in {
  inherit (pkgs.buildPackages) gcc rustc;
  inherit (pkgs) hexyl bash less vim perl cmatrix cowsay;
}
