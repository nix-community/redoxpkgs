{ stdenv, fetchFromGitHub, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-init";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "randd";
    rev = "f32f5c735da396f80fe5dfebe97b81a656cd255b";
    sha256 = "00pwm8kczdg6dzrladlvymsa9m501wl2q08irhabyvzafn98m1j8";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "00nbpizqq0hdj3zlbgjqkq42a5iv7kpzpxaabarnhlj8hrd7137z";

  cargoBuildFlags = [ "-C lto" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/randd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
