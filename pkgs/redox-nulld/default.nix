{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-nulld";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "nulld";
    rev = "24ef80af11302f33eb3c028e16744f2700263dd4";
    sha256 = "0qn0ax7xr43rnlfsn4w8iya5banfsjy2sw672219mdcf64b3wm8c";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "0snrj873mj6d6qalvlpmv8ph62x2mjiijl9vlx77b0p4kzw6l350";

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/ramfs";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
