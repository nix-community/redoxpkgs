{ stdenv, rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage rec {
  name = "coreutils-latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "coreutils";
    rev = "df3400f9c227e68c8e2336b2249256a7a53f32a0";
    sha256 = "0y3hy6z6kq60j7wrbx5f64pfbx5lnm2g1381s1rqf1ha37xa5s45";
  };

  cargoSha256 = "16k1capz75mwipi53wp7li02jx7ixnlpkzrpkhkrckfz6sq4ygfw";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    platforms = platforms.redox ++ platforms.linux;
  };
}
