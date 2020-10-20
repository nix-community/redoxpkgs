{ stdenv, rust, buildPackages, rustPlatform, ion, gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab, relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree }:

stdenv.mkDerivation rec {
  name = "redox-bootloader-latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "bootloader";
    rev = "6adcce54dcfd081d12220ce8319c235ed8fe8030";
    sha256 = "0zv4zr4vp05fshysxv1ipwjf6ds6rk43r7j30f9c2fli1vhz40ar";
  };

  nativeBuildInputs = [ nasm ];

  phases = [ "unpackPhase" "buildPhase" ];

  buildPhase = ''
    nasm -f bin -o $out -D ARCH_x86_64 -ix86_64/ x86_64/disk.asm
  '';
}
