{ runCommandLocal, callPackage, stdenv, rust, buildPackages, rustPlatform, ion, gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab, relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree }:

let
  bootloader = callPackage ./bootloader.nix {};
  rootfs = callPackage ./rootfs.nix {};
in runCommandLocal "redox-vmdisk" {
  nativeBuildInputs = [ nasm redoxfs utillinux ];
} ''
  mkdir $out
  fallocate -l 500M filesystem.bin
  redoxfs-fill filesystem.bin ${rootfs}
  nasm -f bin -o $out/harddrive.bin \
    -D ARCH_x86_64 -D FILESYSTEM=filesystem.bin \
    -i${bootloader.src}/x86_64/ ${bootloader.src}/x86_64/disk.asm
''
