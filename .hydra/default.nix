let
  pkgs = import ../default.nix;
in {
  inherit (pkgs.pkgsCross.x86_64-unknown-redox.buildPackages) gcc rustc;
  inherit (pkgs.pkgsCross.x86_64-unknown-redox)
    hexyl bash less vim
    perl cmatrix cowsay
    binutils-unwrapped
    SDL2 pcre ncurses
    # llvm rcoreutils python37
  ;
}
