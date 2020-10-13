{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig, SDL2 }:

rustPlatform.buildRustPackage rec {
  pname = "redox-drivers";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "drivers";
    rev = "31bae74334d3ab2b7749af40894d97b3b3d733ce";
    sha256 = "1kxvaqvn25libiq4dpwd8ghl6s0n6za625jj4ffmip4g867377rn";
  };

  patches = [ ./minimal-initfs.patch ];

  buildInputs = [ SDL2 ];

  cargoSha256 = "0r0vd5wqn4i82s64vbyhyv6yxib9n2hch45l2mc290sngfl65fqi";
  cargoPatches = [ ./cargo.patch ];

  outputs = [ "out" "dev" ];

  postInstall = ''
    mkdir -p $out/etc/pcid
    cp initfs.toml $out/etc/pcid/initfs.toml

    mkdir -p $out/etc/pcid.d
    for conf in `find . -maxdepth 2 -type f -name 'config.toml'`; do
        driver=$(echo $conf | cut -d '/' -f2)
        cp $conf $out/etc/pcid.d/$driver.toml
    done
  '';

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/drivers";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
