{ stdenv, fetchFromGitHub, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redoxfs";
  version = "0.4.0";

  src = fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/redoxfs";
    rev = "0068a6d4980e83e36c2f08fd64e4809da5ce136c";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ fuse ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1wpv8mamv0f5rc5j3z1xc2sfvd3zh4zm11kwi4my2klfw3x37rlp";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/redoxfs";
    maintainers = with maintainers; [ aaronjanse ];
  };
}
