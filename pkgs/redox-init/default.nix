{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "redox-init";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "init";
    rev = "ec060cca50781c2536ce89c666a410502535747b";
    sha256 = "1y1cn5n5ybgm46kf2crp2qkwkf420xsg5djkxcfyyjh13calsw6b";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  outputs = [ "out" "dev" ];

  cargoSha256 = "10n58cwil9njqjyxwka1k54fk0r1cwngaarnnz7lbrgf8d4nhml3";

  # cargoBuildFlags = [ "lto" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/init";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
