{ stdenv, fetchFromGitHub, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname   = "redoxfs";
  version = "0.4.0";

  src = fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/redoxfs";
    rev = "0068a6d4980e83e36c2f08fd64e4809da5ce136c";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ fuse ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1wpv8mamv0f5rc5j3z1xc2sfvd3zh4zm11kwi4my2klfw3x37rlp";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    changelog = "https://github.com/sharkdp/hexyl/releases/tag/v${version}";
    description = "A command-line hex viewer";
    longDescription = ''
      `hexyl` is a simple hex viewer for the terminal. It uses a colored
      output to distinguish different categories of bytes (NULL bytes,
      printable ASCII characters, ASCII whitespace characters, other ASCII
      characters and non-ASCII).
    '';
    homepage    = "https://github.com/sharkdp/hexyl";
    license     = with licenses; [ asl20 /* or */ mit ];
    maintainers = with maintainers; [ dywedir ];
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
