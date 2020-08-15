{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "redox-randd";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "randd";
    rev = "2f0ad188dd3e0393567fa91567bf1989465507c0";
    sha256 = "00nlfbx9gbmmpnd24kiyl5213zhsxq4kl3zfh9lnyx9qy1xdhdjd";
  };

  cargoSha256 = "03j4wvpv67zbng8yhxlq5iyh452yhkl4b8z15975a7lprxj40pwj";

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/randd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
