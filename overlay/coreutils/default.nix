{ stdenv, rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage rec {
  name = "coreutils-latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "coreutils";
    rev = "88e626740be4f4290431efdaceaba198a1b22994";
    sha256 = "1x5lgn4bd2g5qywzzzr38i9aawhgxgl00b5qb975zai0q7r4aa92";
  };

  cargoSha256 = "05ww4q2ih75r7p892845dxwq91zycfxkqrgh537gwhz7qi037j3b";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    platforms = platforms.redox ++ platforms.linux;
  };
}
