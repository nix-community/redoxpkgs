{ stdenv, ion, breakpointHook, redoxPkgs, utillinux, fetchFromGitLab, relibc, redoxfs, fetchgit, rustPlatform, fuse, pkgconfig, nasm, tree }:

let
  bootloader = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "bootloader";
    rev = "6adcce54dcfd081d12220ce8319c235ed8fe8030";
    sha256 = "0zv4zr4vp05fshysxv1ipwjf6ds6rk43r7j30f9c2fli1vhz40ar";
  };

  initfsPkgs = with redoxPkgs; [
    drivers init nulld ramfs randd redoxfs zerod
  ];

  userPkgs = with redoxPkgs; [
    drivers ion ipcd logd ptyd relibc
  ];

  install = pkgs: dest: ''
    function install {
      cp -R $1/* ${dest}/
    }

    ${builtins.concatStringsSep "\n" (builtins.map (v: "install ${v}") pkgs)}
  '';

in rustPlatform.buildRustPackage rec {
  pname   = "redox-iso";
  version = "latest";

  dontStrip = true;

  # src = fetchgit {
  #   url = "https://gitlab.redox-os.org/redox-os/kernel";
  #   rev = "895c0c11da8e42a4e2177e69cd318c9db26c166c";
  #   sha256 = "17q8bqb2insgdcnalx4wwl3524wxd586ywmps42ypc9ssgmblsys";
  #   fetchSubmodules = true;
  # };
  src = /home/ajanse/redox/redox/kernel;

  buildType = "debug";
  RUSTFLAGS = "-C debuginfo=2 -C lto=thin -C soft-float";

  nativeBuildInputs = [
    nasm redoxfs tree utillinux
  ];

  patchPhase = ''
    mkdir -p build/initfs/{etc,bin,tmp}

    cat << EOF > build/initfs/etc/init.rc
    echo "Hello. I start things."
    export PATH /bin
    export TMPDIR /tmp
    nulld
    zerod
    randd
    vesad T T G
    stdio display:1
    ps2d us
    ramfs logging
    pcid /etc/pcid/initfs.toml
    echo "Hello, world"
    echo \$REDOXFS_UUID
    redoxfs --uuid \$REDOXFS_UUID file \$REDOXFS_BLOCK
    echo "Okay, we are mounted now, I think"
    cd file:
    export PATH file:/bin
    run.d /etc/init.d
    EOF

    ${install initfsPkgs "build/initfs"}

    tree build/initfs

    nasm -f bin -o build/bootloader -D ARCH_x86_64 -i${bootloader}/x86_64/ ${bootloader}/x86_64/disk.asm

    export INITFS_FOLDER=$PWD/build/initfs
  '';

  postInstall = ''
    echo "Setting up kernel..."
    mkdir -p $out

    x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 -T linkers/x86_64.ld -o build/kernel $out/lib/libkernel.a
    x86_64-unknown-redox-objcopy --only-keep-debug build/kernel build/kernel.sym
    x86_64-unknown-redox-objcopy --strip-debug build/kernel


    dd if=/dev/zero of=build/filesystem.bin.partial bs=1048576 count="256"

    redoxfs-mkfs build/filesystem.bin.partial
    mkdir -p build/filesystem/
    # redoxfs build/filesystem.bin.partial build/filesystem/
    # sleep 2
    
    echo "Creating filesystem..."
    mkdir -p build/filesystem/{bin,share,tmp,games,etc}
    mkdir -p build/filesystem/etc/init.d

    cp build/bootloader build/filesystem/bootloader
    cp build/kernel build/filesystem/kernel

    ${install userPkgs "build/filesystem"}

    cat << EOF > build/filesystem/etc/init.d/00_base
    ipcd
    logd
    ptyd
    echo "Hello, world"
    pcid /etc/pcid.d/
    EOF

    cat << EOF > build/filesystem/etc/init.d/30_console
    getty display:2/activate
    getty debug: -J
    EOF

    # FIXME: should be symlinks
    mkdir -p build/filesystem/usr
    cp -r build/filesystem/bin build/filesystem/usr/bin
    cp -r build/filesystem/games build/filesystem/usr/games
    cp -r build/filesystem/include build/filesystem/usr/include
    cp -r build/filesystem/lib build/filesystem/usr/lib
    cp -r build/filesystem/share build/filesystem/usr/share

    echo "Creating users..."

    mkdir -p build/filesystem/root
    chmod 777 -R build/filesystem/root

    mkdir -p build/filesystem/home/user
    chmod 777 -R build/filesystem/home/user

    cat << EOF > build/filesystem/etc/passwd
    root;0;0;root;file:/root;file:/bin/ion
    user;1;1;user;file:/home/user;file:/bin/ion
    EOF

    cat << EOF > build/filesystem/etc/shadow
    root;
    user;
    EOF

    # sync
    # fusermount -u build/filesystem/ || true
    # mv build/filesystem.bin.partial build/filesystem.bin
    # exit


    mkdir -p $out

    # echo "Wrapping filesystem with redoxfs..."
    redoxfs-ar build/filesystem.bin build/filesystem/
    nasm -f bin -o $out/harddrive.bin -D ARCH_x86_64 -D FILESYSTEM=build/filesystem.bin -i${bootloader}/x86_64/ ${bootloader}/x86_64/disk.asm

    echo $out/harddrive.bin

    cp -r build/ $out/

    echo "Finishing up..."

    cp -r ${bootloader}/x86_64 $out

    # nasm -f bin -o $out/harddrive.bin -D ARCH_x86_64 -D FILESYSTEM=build/filesystem.bin -i${bootloader}/x86_64/ ${bootloader}/x86_64/disk.asm

    echo "> symbol-file $out/build/kernel.sym"
    echo "> target remote localhost:1234"
  '';

  # buildPhase = ''
  #   rustc --target x86_64-unknown-none -- -C soft-float -C debuginfo=2 --emit link=../build/libkernel.a
  # '';
  doCheck = false;

  # INITFS_FOLDER = "$src/build/initfs";
  # cargoFlags = [ "--verbose" ];

  cargoSha256 = "1w3hmjhy8fnkh419j2617knjixwjll44wl7c2vpr57nviwry8lrh";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/kernel";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}

# { stdenv, rustc, fetchFromGitLab, nasm, tree, fetchgit, redoxPkgs, pkgsCross }:

# let
#   pkgsCrossRedox = pkgsCross.x86_64-unknown-redox;
# in
# stdenv.mkDerivation {
#   pname   = "redox-iso";
#   version = "latest";

#   # src = fetchgit {
#   #   url = "https://gitlab.redox-os.org/redox-os/redox";
#   #   rev = "a8e604f46dafa7ba73aa7b9d32f8b37d9a83b7d4";
#   #   fetchSubmodules = true;
#   #   sha256 = "0z3sln62rfcwg1wn9ix2svh7nmnswj8nga8d10fh70c7lwrpvlvi";
#   # };
#   dontUnpack = true;

#   nativeBuildInputs = [
    
#   ];

#   buildInputs = [
    
#   ];


#   buildPhase = ''
#     mkdir -p build
#     cp ${kernel}/lib/libkernel.a build/
#     x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 -T kernel/linkers/x86_64.ld -o build/kernel build/libkernel.a
#   '';

#   dontInstall = true;
#   dontFixup = true;
#   dontCheck = true;

#   meta = with stdenv.lib; {
#     homepage    = "https://gitlab.redox-os.org/redox-os/redox";
#     maintainers = with maintainers; [ aaronjanse ];
#   };
# }

/*

# mkdir -p build

# export REDOXER_TOOLCHAIN="/home/ajanse/redox/redox-nix/redox/prefix/x86_64-unknown-redox/relibc-install"

# nasm -f bin -o build/bootloader -D ARCH_x86_64 -ibootloader/x86_64/ bootloader/x86_64/disk.asm

# mkdir -p build/initfs

# redox_installer --cookbook=cookbook -c initfs.toml build/initfs/
# touch build/initfs.tag

# cd kernel

# export INITFS_FOLDER=${./build/initfs} && \\
# ${redox-binary-toolchain}/bin/xargo rustc --lib --target x86_64-unknown-none --release -- -C soft-float -C debuginfo=2 -C lto --emit link=../build/libkernel.a

# x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 -T kernel/linkers/x86_64.ld -o build/kernel build/libkernel.a && \
# x86_64-unknown-redox-objcopy --only-keep-debug build/kernel build/kernel.sym && \
# x86_64-unknown-redox-objcopy --strip-debug build/kernel

# cargo build --manifest-path redoxfs/Cargo.toml --release

# dd if=/dev/zero of=build/filesystem.bin.partial bs=1048576 count="256"

# cargo run --manifest-path redoxfs/Cargo.toml --release --bin redoxfs-mkfs build/filesystem.bin.partial

# mkdir -p build/filesystem/
# redoxfs/target/release/redoxfs build/filesystem.bin.partial build/filesystem/
# sleep 2
# pgrep redoxfs

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
