{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-drivers";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "drivers";
    rev = "a16604fc2cb78238317ed80a780c51875e321d51";
    sha256 = "000wm8kczdg6dzrladlvymsa9m501wl2q08irhabyvzafn98m1j8";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "00rdpykcvcrgy6s5qi6v7sw4j3ihbz3w4jfavxxaqsbjdhp52ys1";

  patches = [ ./fix-asm.patch ];

  cargoPatches = [
    ./fix-Cargo.lock.patch
  ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/drivers";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
