{ stdenv, initfs, rust, buildPackages, rustPlatform, ion, gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab, relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree }:

rustPlatform.buildRustPackage rec {
  name = "redox-kernel-latest";

  src = fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/kernel";
    rev = "0590a71b8759c773cd961680ed9f4c35474bd748";
    sha256 = "1cdf5bc0b0fjr8k7p8maax8dm2w9i9jz5j64a579yxb4hy7zzhda";
    fetchSubmodules = true;
  };

  cargoSha256 = "19dim0py5sqg2a0ifjz1q9vzzfzlmw90n4wqlsc9yxc553kla728";

  nativeBuildInputs = [ nasm ];

  INITFS_FOLDER = initfs;

  target = src + /targets/x86_64-unknown-none.json;
  buildType = "debug";
  RUSTFLAGS = "-C debuginfo=2 -C soft-float -C lto=thin -C embed-bitcode=yes";
  RUSTC_BOOTSTRAP = 1;

  doCheck = false;

  outputs = [ "out" "dev" ];
  dontPatchShebangs = true;
  dontStrip = true;

  postInstall = ''
    cp $out/lib/libkernel.a .
    rm -rf $out
    mkdir $dev

    x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 \
      -T linkers/x86_64.ld -o $out libkernel.a
    x86_64-unknown-redox-objcopy --only-keep-debug $out $dev/kernel.sym
    x86_64-unknown-redox-objcopy --strip-debug $out
  '';
}
