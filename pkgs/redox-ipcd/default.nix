{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "redox-ipcd";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "ipcd";
    rev = "328b88a4a4fa4a0cf4804fccb18cc035cdd3c0de";
    sha256 = "1nk5gksdj41kla6ilphb3kzg01smcysrw1mnl9qky7d2fd22hx3g";
  };

  cargoSha256 = "07zkhf9w4fhjm200svsg53f6dgkl2qg1kvp23m7xlb2q2408r5ps";

  RUSTC_BOOTSTRAP = 1;

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/ipcd";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
