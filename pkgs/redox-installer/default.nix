{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "installer";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "installer";
    rev = "150d65c31ba05c829ba239a3febe1e44b6e512e8";
    sha256 = "1zpfyix6prdy0dl19gx7k5xy6wyc9cslhkc2rk7igknxnjgv4414";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ fuse ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "0j9z0s4fiv1y0q3dz3ns5amq5r3yjnl8a82474zb8ndbrmkzvj4s";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/redoxfs";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.linux;
  };
}
