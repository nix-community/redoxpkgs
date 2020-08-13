{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-logd";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "logd";
    rev = "293f4fb9885fffe9fdb59e03fca7897a34a8a649";
    sha256 = "00pj4r5ml5s4927cnwa0vpnrqxqkvgharjffi452hs3k5jh5scqn";
  };

  cargoSha256 = "1n0baxkwwj3x0x7j2jgk0bvv03a0mcam4iq7v20sr0k7v93hq5pb";

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/logd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
