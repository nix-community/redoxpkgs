{ stdenv, buildPackages, fetchurl, lib, makeRustPlatform }:
let
  rpath = lib.makeLibraryPath [
    buildPackages.stdenv.cc.libc
    "$out"
  ];
  bootstrapCrossRust = stdenv.mkDerivation {
    name = "binary-redox-rust";

    src = fetchurl {
      name = "rust-install.tar.gz";
      url = "https://gateway.pinata.cloud/ipfs/QmNp6fPTjPA6LnCYvW1UmbAHcPpU7tqZhstfSpSXMJCRwp";
      sha256 = "1hjdzrj67jdag3pm8h2dqh6xipbfxr6f4navdra6q1h83gl7jkd9";
    };

    dontBuild = true;
    dontPatchELF = true;
    dontStrip = true;
    installPhase = ''
      mkdir $out/
      cp -r * $out/

      find $out/ -executable -type f -exec patchelf \
          --set-interpreter "${buildPackages.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          --set-rpath "${rpath}" \
          "{}" \;
      find $out/ -name "*.so" -type f -exec patchelf \
          --set-rpath "${rpath}" \
          "{}" \;
    '';

    meta.platforms = with stdenv.lib; platforms.redox ++ platforms.linux;
  };
in
buildPackages.makeRustPlatform {
  rustc = bootstrapCrossRust;
  cargo = bootstrapCrossRust;
}
