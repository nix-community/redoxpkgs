{ stdenv, nasm, tree, fetchgit, redoxPkgs, pkgsCross }:

let
  pkgsCrossRedox = pkgsCross.x86_64-unknown-redox;
in
stdenv.mkDerivation {
  pname   = "redox";
  version = "0.5.0";

  src = fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/redox";
    rev = "a8e604f46dafa7ba73aa7b9d32f8b37d9a83b7d4";
    fetchSubmodules = true;
    sha256 = "0z3sln62rfcwg1wn9ix2svh7nmnswj8nga8d10fh70c7lwrpvlvi";
  };

  nativeBuildInputs = [
    nasm tree redoxPkgs.installer
  ];

  buildInputs = [
    pkgsCrossRedox.redoxPkgs.drivers
  ];


  buildPhase = ''
    mkdir -p build
    nasm -f bin -o build/bootloader -D ARCH_x86_64 -ibootloader/x86_64/ bootloader/x86_64/disk.asm
    mkdir -p build/initfs
  '';

  dontInstall = true;
  dontFixup = true;
  dontCheck = true;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/redox";
    maintainers = with maintainers; [ aaronjanse ];
  };
}
