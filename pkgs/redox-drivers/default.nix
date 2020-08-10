{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig, SDL2 }:

rustPlatform.buildRustPackage rec {
  pname   = "redox-drivers";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "drivers";
    rev = "be101621cce424712ecd304de4096b2167857158";
    sha256 = "1900mz90hl608404zk903qy6i9mv1nkzh1krz68w1gvf6xxd2a2d";
  };

  buildInputs = [ SDL2 ];

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "14zh6cm0fdmpsc1snl8lppy1knvqyw3qwzza1riry0dyg3snykbr";

  # patches = [ ./fix-asm.patch ];

  # cargoPatches = [
  #   ./fix-Cargo.lock.patch
  # ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/drivers";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
