{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "redox-ramfs";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "ramfs";
    rev = "4343ac6b5491f479067d94255fc3555fd9d0b924";
    sha256 = "1xraa4fyzf8qy4jz249ip0d16vdg8k5whlr16hjl3kdc03xdw937";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1q6bjx10jjh062hp2vcm2zdij89xs5n6yrlhpv34mi45kp0s11zh";

  # cargoBuildFlags = [ "-C lto" ];

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/randd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
