{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage ({
  pname = "redoxfs";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "redoxfs";
    rev = "f1b88c38c0a9b6bf9e24f82397a8a9505c9a2df2";
    sha256 = "0s0ya4vig2kn86xbq6fb6mylajhx75r24hs07xgmdxzsqqn1yqxa";
  };

  nativeBuildInputs = [ pkgconfig ];

  cargoSha256 = "17aq6mc6f22p1ba9jgspzpl0xgac4n9h6m1mix0z28avfachislb";

  RUSTC_BOOTSTRAP = 1;

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/redoxfs";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.linux ++ platforms.redox;
  };
} // (
  if (!stdenv.hostPlatform.isRedox) then {
    propagatedBuildInputs = [ fuse ];
    PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";
  } else { }
))
