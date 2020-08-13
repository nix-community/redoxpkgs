{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:


rustPlatform.buildRustPackage rec {
  pname   = "redox-zerod";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "zerod";
    rev = "9888f74802ac7a252c320d2bc199e218baaf152d";
    sha256 = "1k0qhglpy6s341vi70idhz68895zflhqn4a14yskfkfcl54ngsxk";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "01gh4xjkmrzsmv9i8rd5yfjnhrx6nr2q4y4gc7aziikyk5x6c9hn";

  # cargoBuildFlags = [ "-C lto" ];

  outputs = [ "out" "dev" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/zerod";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
