{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

/*

mkdir -p build

export REDOXER_TOOLCHAIN="/home/ajanse/redox/redox-nix/redox/prefix/x86_64-unknown-redox/relibc-install"

nasm -f bin -o build/bootloader -D ARCH_x86_64 -ibootloader/x86_64/ bootloader/x86_64/disk.asm

mkdir -p build/initfs

redox_installer --cookbook=cookbook -c initfs.toml build/initfs/
touch build/initfs.tag

cd kernel

export INITFS_FOLDER=${./build/initfs} && \\
${redox-binary-toolchain}/bin/xargo rustc --lib --target x86_64-unknown-none --release -- -C soft-float -C debuginfo=2 -C lto --emit link=../build/libkernel.a

x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 -T kernel/linkers/x86_64.ld -o build/kernel build/libkernel.a && \
x86_64-unknown-redox-objcopy --only-keep-debug build/kernel build/kernel.sym && \
x86_64-unknown-redox-objcopy --strip-debug build/kernel

cargo build --manifest-path redoxfs/Cargo.toml --release

dd if=/dev/zero of=build/filesystem.bin.partial bs=1048576 count="256"

cargo run --manifest-path redoxfs/Cargo.toml --release --bin redoxfs-mkfs build/filesystem.bin.partial

mkdir -p build/filesystem/
redoxfs/target/release/redoxfs build/filesystem.bin.partial build/filesystem/
sleep 2
pgrep redoxfs

cp filesystem.toml build/filesystem/filesystem.toml
cp build/bootloader build/filesystem/bootloader
cp build/kernel build/filesystem/kernel
cp -r ${relibc}/include build/filesystem/include
cp -r ${relibc}/lib build/filesystem/lib

redox_installer --cookbook=cookbook -c filesystem.toml build/filesystem/

sync
fusermount -u build/filesystem/ || true
rm -rf build/filesystem/
mv build/filesystem.bin.partial build/filesystem.bin

# build/livedisk.bin
hr ; echo "build/harddrive.bin" ; hr
nasm -f bin -o build/harddrive.bin -D ARCH_x86_64 -D FILESYSTEM=build/filesystem.bin -ibootloader/x86_64/ bootloader/x86_64/disk.asm


*/

rustPlatform.buildRustPackage rec {
  pname   = "redox-init";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "zerod";
    rev = "549eb4675aa70e02ade4e763e210c681df698dfe";
    sha256 = "000wm8kczdg6dzrladlvymsa9m501wl2q08irhabyvzafn98m1j8";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # propagatedBuildInputs = [ fuse ];

  # PKG_CONFIG_PATH = "${fuse}/lib/pkgconfig";

  cargoSha256 = "00nbpizqq0hdj3zlbgjqkq42a5iv7kpzpxaabarnhlj8hrd7137z";

  cargoBuildFlags = [ "-C lto" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/zerod";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
