{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-liborbital";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "liborbital";
    rev = "73c4fe9b7f17a086235162d729f7a8afbc0d6730";
    sha256 = "157kfdwbadxwzrsi2scr2qsnlhnkfrpsqqjxs3l75jp4bicgxgv1";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "0v41z1ms11x54sfq7mm91l64j2hy251i5paz07r772lrw3wbvn42";

  # cargoBuildFlags = [ "-C lto" ];

  postInstall = ''
    mkdir -p $out/include
    cp include/orbital.h $out/include/
  '';

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/randd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
