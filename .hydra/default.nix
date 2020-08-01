let
  pkgs = import ../default.nix;
in {
  inherit (pkgs.buildPackages) rustc;
}
