{ stdenv, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "coreutils-latest";

  src = fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/coreutils";
    rev = "88e626740be4f4290431efdaceaba198a1b22994";
  };

  cargoSha256 = "05ww4q2ih75r7p892845dxwq91zycfxkqrgh537gwhz7qi037j3b";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    platforms = platforms.redox ++ platforms.linux;
  };
}
