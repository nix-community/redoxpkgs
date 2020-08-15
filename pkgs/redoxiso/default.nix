{ stdenv, rust, buildPackages, rustPlatform, ion, gnutar, breakpointHook, redoxPkgs, utillinux, fetchFromGitHub, fetchFromGitLab, relibc, redoxfs, fetchgit, fuse, pkgconfig, nasm, tree }:

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
    drivers ion ipcd logd ptyd relibc userutils
  ];

  install = pkgs: dest: ''
    function install {
      cp -R $1/* ${dest}/
    }
  '' + builtins.concatStringsSep "\n"(builtins.map
        (v: "install ${v}") pkgs);

in rustPlatform.buildRustPackage rec {
  pname   = "redox-iso";
  version = "latest";

  dontStrip = true;

  src = fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/kernel";
    rev = "895c0c11da8e42a4e2177e69cd318c9db26c166c";
    sha256 = "17q8bqb2insgdcnalx4wwl3524wxd586ywmps42ypc9ssgmblsys";
    fetchSubmodules = true;
  };

  buildType = "debug";
  RUSTFLAGS = "-C debuginfo=2 -C soft-float -C lto=thin -C embed-bitcode=yes";

  target = src + /targets/x86_64-unknown-none.json;

  nativeBuildInputs = [
    nasm redoxfs tree utillinux
  ];

  patchPhase = ''
    mkdir -p build/initfs/{etc,bin,tmp}

    cat << EOF > build/initfs/etc/init.rc
    export PATH /bin
    export TMPDIR /tmp
    nulld
    zerod
    randd
    vesad T T G
    ps2d us
    ramfs logging
    pcid /etc/pcid/initfs.toml
    redoxfs --uuid \$REDOXFS_UUID file \$REDOXFS_BLOCK
    cd file:
    export PATH file:/bin
    run.d /etc/init.d
    EOF

    ${install initfsPkgs "build/initfs"}

    chmod +rw -R build/initfs/etc/pcid.d/
    rm -rf build/initfs/etc/pcid.d/

    nasm -f bin -o build/bootloader -D ARCH_x86_64 -i${bootloader}/x86_64/ ${bootloader}/x86_64/disk.asm

    export INITFS_FOLDER=$PWD/build/initfs
  '';

  postInstall = ''
    mkdir -p $out

    x86_64-unknown-redox-ld --gc-sections -z max-page-size=0x1000 -T linkers/x86_64.ld -o build/kernel $out/lib/libkernel.a
    x86_64-unknown-redox-objcopy --only-keep-debug build/kernel build/kernel.sym
    x86_64-unknown-redox-objcopy --strip-debug build/kernel

    dd if=/dev/zero of=build/filesystem.bin.partial bs=1048576 count="256"

    redoxfs-mkfs build/filesystem.bin.partial

    mkdir -p build/filesystem/{bin,share,tmp,games,etc/init.d}

    cp build/bootloader build/filesystem/bootloader
    cp build/kernel build/filesystem/kernel

    ${install userPkgs "build/filesystem"}

    cat << EOF > build/filesystem/etc/init.d/00_base
    ipcd
    logd
    ptyd
    pcid /etc/pcid.d/
    EOF

    cat << EOF > build/filesystem/etc/init.d/30_console
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

    mkdir -p $out
    redoxfs-ar build/filesystem.bin build/filesystem/
    nasm -f bin -o $out/harddrive.bin -D ARCH_x86_64 -D FILESYSTEM=build/filesystem.bin -i${bootloader}/x86_64/ ${bootloader}/x86_64/disk.asm
  '';

  doCheck = false;

  cargoSha256 = "1w3hmjhy8fnkh419j2617knjixwjll44wl7c2vpr57nviwry8lrh";

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage    = "https://gitlab.redox-os.org/redox-os/kernel";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox ++ platforms.linux;
  };
}
