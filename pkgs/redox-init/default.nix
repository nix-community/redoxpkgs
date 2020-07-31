{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-init";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "init";
    rev = "396750c2da1f853e6556c264da75ff57a7af9452";
    sha256 = "1cshqr5lgmlxc8n71dr6k5933kr2mann0har49hh9brwlrxjq4mr";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "00nbpizqq0hdj3zlbgjqkq42a5iv7kpzpxaabarnhlj8hrd7137z";

  cargoBuildFlags = [ "-C lto" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/init";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
