{ runCommandLocal, callPackage, stdenv, rust, buildPackages, rustPlatform, ion,
  gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab,
  relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree, redox-rootfs }:

let
  bootloader = callPackage ./bootloader.nix {};

  vmForRoot = rootfs:
    runCommandLocal "redox-vmdisk" {
      nativeBuildInputs = [ nasm redoxfs utillinux ];
    } ''
      mkdir $out
      dd if=/dev/zero of=filesystem.bin bs=500M seek=1 count=0
      redoxfs-fill filesystem.bin ${rootfs}
      nasm -f bin -o $out/harddrive.bin \
        -D ARCH_x86_64 -D FILESYSTEM=filesystem.bin \
        -i${bootloader.src}/x86_64/ ${bootloader.src}/x86_64/disk.asm
    '';

  vm = vmForRoot redox-rootfs;
in

vm // {
  withRootFS = vmForRoot;
  withPackages = f: vmForRoot (redox-rootfs.withPackages f);
}
