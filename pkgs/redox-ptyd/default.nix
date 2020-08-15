{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "redox-ptyd";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "ptyd";
    rev = "ccd65a0c88bdf710d9f50eb52a703fbb87daa6ce";
    sha256 = "1993l4s5xwxgpzzn2qylfq74xdwdr81nf24153k20gyl084lxyaz";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1z71zixliyybmr3vf6ys75r8mbd440xag4pr1hvi7m5adx20k8kz";

  # cargoBuildFlags = [ "lto" ];

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/ptyd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
