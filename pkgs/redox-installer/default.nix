{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redoxfs";
  version = "0.4.0";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "redoxfs";
    rev = "0068a6d4980e83e36c2f08fd64e4809da5ce136c";
    sha256 = "1apwm8kczdg6dzrladlvymsa9m501wl2q08irhabyvzafn98m1j8";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ fuse ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1wpv8mamv0f5rc5j3z1xc2sfvd3zh4zm11kwi4my2klfw3x37rlp";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/redoxfs";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.linux;
  };
}
