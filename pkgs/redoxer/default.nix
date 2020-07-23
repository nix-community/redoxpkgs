{ stdenv, fetchFromGitHub, rustPlatform, fuse, pkgconfig, redoxfs }:

rustPlatform.buildRustPackage rec {
  pname   = "redoxer";
  version = "0.2.19";

  src = fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/redoxer";
    rev = "186d5b26b5381e961ed05ddf6ff477c7b93da7bf";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ fuse redoxfs ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1bmflfgwj0vx1l1s2yqh251svsrcak128apd6hq6j3lwwra0kpkv";

  RUSTC_BOOTSTRAP = 1;

  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${stdenv.lib.makeBinPath [ redoxfs ]}"
  ];


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
