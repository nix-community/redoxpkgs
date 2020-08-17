{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage ({
  pname = "redoxfs";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "aaronjanse";
    repo = "redoxfs";
    rev = "2b8d25f9130d1ad66f2da7012d48a1407f99b146";
    sha256 = "1fnq3c107vg2fpn06hm7kpqhij0k4qq1w86axk3z00x1yqdyxbbf";
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
