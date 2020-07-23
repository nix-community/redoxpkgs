{ stdenv, lib, fetchFromGitHub, rustPlatform, fuse, pkgconfig, redoxfs, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname   = "redoxer";
  version = "0.2.19";

  src = fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/redoxer";
    rev = "186d5b26b5381e961ed05ddf6ff477c7b93da7bf";
  };

  nativeBuildInputs = [ pkgconfig makeWrapper ];
  propagatedBuildInputs = [ fuse redoxfs ];

  PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "1bmflfgwj0vx1l1s2yqh251svsrcak128apd6hq6j3lwwra0kpkv";

  RUSTC_BOOTSTRAP = 1;

  postInstall = ''
    wrapProgram $out/bin/redoxer \
      --prefix PATH : "${lib.makeBinPath [ redoxfs ]}"
  '';

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/redoxer";
    maintainers = with maintainers; [ aaronjanse ];
  };
}
