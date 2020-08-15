{ stdenv, initfs, rust, buildPackages, rustPlatform, ion, gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab, relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree }:

rustPlatform.buildRustPackage rec {
  name = "redox-kernel-latest";

  src = fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/kernel";
    rev = "895c0c11da8e42a4e2177e69cd318c9db26c166c";
    sha256 = "17q8bqb2insgdcnalx4wwl3524wxd586ywmps42ypc9ssgmblsys";
    fetchSubmodules = true;
  };

  cargoSha256 = "08z29g2maq5w2hwfy1pgdrqs4wdn6v8631b1ifndjkahg719wzax";

  nativeBuildInputs = [ nasm ];

  INITFS_FOLDER = initfs;

  target = src + /targets/x86_64-unknown-none.json;
  buildType = "debug";
  RUSTFLAGS = "-C debuginfo=2 -C soft-float -C lto=thin -C embed-bitcode=yes";
  RUSTC_BOOTSTRAP = 1;

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
