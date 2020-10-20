{ stdenv }:

stdenv.mkDerivation rec {
  pname = "pwd";
  version = "latest";

  src = ./main.c;
  buildPhase = ''
    mkdir -p $out/bin
    $CC -o $out/bin/pwd $src
  '';

  dontUnpack = true;
  dontCheck = true;
  dontInstall = true;

  preferLocal = true;
}
