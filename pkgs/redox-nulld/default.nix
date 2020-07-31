{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-ramfs";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "ramfs";
    rev = "ec847e309dfda3426a9b6292bac9ceaf18bc712e";
    sha256 = "0apwm8kczdg6dzrladlvymsa9m501wl2q08irhabyvzafn98m1j8";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "00nbpizqq0hdj3zlbgjqkq42a5iv7kpzpxaabarnhlj8hrd7137z";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/ramfs";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
