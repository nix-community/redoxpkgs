{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:


rustPlatform.buildRustPackage rec {
  pname = "redox-userutils";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "userutils";
    rev = "c33a46452250c2f577f8c60a705533e891c5d139";
    sha256 = "1bap1bnzgpwk8q09frlvyhwzr422xw8pnqwfql7x8341d7ykh748";
  };

  cargoSha256 = "0h0fjjbjp2p6vbzby5v7hz9xdh1rah0apg38cchs6g1qyp9lr83i";

  outputs = [ "out" "dev" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/userutils";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
