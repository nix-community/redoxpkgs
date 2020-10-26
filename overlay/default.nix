self: super:
let
  whenHost = pkg: fix:
    if self.stdenv.hostPlatform.isRedox
    then pkg.overrideAttrs fix
    else pkg;

  whenTarget = pkg: fix:
    if self.stdenv.targetPlatform.isRedox
    then pkg.overrideAttrs fix
    else pkg;

  whenAlways = pkg: fix: pkg.overrideAttrs fix;

in
{
  b3sum = whenHost super.b3sum (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
  });

  bat = whenHost super.bat (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
  });

  bash = whenHost super.bash (attrs: rec {
    patchFlags = [ ];
    patches = [ ./bash/redox.patch ];
    configureFlags = [
      "--disable-readline"
      "bash_cv_getcwd_malloc=no"
      "--without-bash-malloc"
      "--disable-nls"
      "bash_cv_getenv_redef=no"
    ];
    nativeBuildInputs = attrs.nativeBuildInputs ++ [ self.buildPackages.autoconf ];
  });

  binutils = whenHost super.binutils (attrs: rec {
    nativeBuildInputs = (with self; [ texinfo flex ]);
    configureFlags = [
      "--disable-gdb"
      "--disable-nls"
    ];
    src = self.fetchFromGitLab {
      domain = "gitlab.redox-os.org";
      owner = "redox-os";
      repo = "binutils-gdb";
      rev = "692afe7cc2d41134d08e5c487ddad125d5aaec5e";
      sha256 = "0vngaqvpd1f7clx07rw4m5aqabxqbxsy5jp7056gn19xb9wr9yvw";
    };
    patches = [
      ./binutils/deterministic.patch
      ./binutils/disambiguate-arm-targets.patch
      ./binutils/always-search-rpath.patch
    ];
  });

  boehmgc = whenHost super.boehmgc (attrs: rec {
    patches = attrs.patches ++ [ ./boehmgc/redox.patch ];
    nativeBuildInputs = [ self.buildPackages.autoreconfHook ];
  });

  pwd = self.callPackage ./pwd { };

  # coreutils = if self.stdenv.hostPlatform.isRedox
  #   then self.callPackage ./coreutils {}
  #   else super.coreutils;

  rcoreutils = self.callPackage ./coreutils { };

  curl = whenHost super.curl (attrs: rec {
    src = self.fetchFromGitLab {
      domain = "gitlab.redox-os.org";
      owner = "redox-os";
      repo = "curl";
      rev = "1c5963a79ba69bc332865dfbfc2cddc7e545dc80";
      sha256 = "16y2137j2z6niw9jjspb252k2wrgl8yj43p0rki74qqahlvzv0p9";
    };
    preConfigure = ''
      sed -e 's|/usr/bin|/no-such-path|g' -i.bak configure
    '';
    configureFlags = attrs.configureFlags ++ [
      "--disable-ftp"
      "--disable-ipv6"
      "--disable-ntlm-wb"
      "--disable-tftp"
      "--disable-threaded-resolver"
      "--disable-shared"
      "--enable-static"
    ];
  });

  git = super.git.overrideAttrs (attrs: rec {
    doCheck = false;
  });

  # gcc6 = whenTarget super.gcc6 (attrs: rec {
  #   src = fetchGit {
  #     url = https://gitlab.redox-os.org/redox-os/gcc;
  #     rev = "f360ac095028d286fc6dde4d02daed48f59813fa";
  #   };
  #   nativeBuildInputs = with self; [ texinfo which gettext flex ];
  #   patches = [];
  #   # configureFlags = map (x: if (x == "--enable-nls")
  #   #   then "--disable-nls"
  #   #   else x
  #   # ) attrs.configureFlags;
  # });

  gettext = whenHost super.gettext (attrs: rec {
    version = "0.19.8.1";
    src = super.fetchurl {
      url = "mirror://gnu/gettext/gettext-${version}.tar.gz";
      sha256 = "0hsw28f9q9xaggjlsdp2qmbp2rbd1mp0njzan2ld9kiqwkq2m57z";
    };
    patches = [ ./gettext/absolute-paths.diff ./gettext/redox.patch ];
  });

  gmp = whenHost super.gmp (attrs: rec {
    name = "gmp-6.1.0";
    src = self.fetchurl {
      urls = [
        "mirror://gnu/gmp/${name}.tar.bz2"
        "ftp://ftp.gmplib.org/pub/${name}/${name}.tar.bz2"
      ];
      sha256 = "1s3kddydvngqrpc6i1vbz39raya2jdcl042wi0ksbszgjjllk129";
    };
    patches = [ ./gmp/redox.patch ];
    configurePlatforms = [ "build" "host" ];
    configureFlags = builtins.filter
      (x: !builtins.elem x [
        "--with-pic"
        "--enable-cxx"
      ])
      attrs.configureFlags;
  });

  gnugrep = whenHost super.gnugrep (attrs: rec {
    patches = [ ./gnugrep/redox.patch ];
  });

  gnused = whenHost super.gnused (attrs: rec {
    version = "4.4";
    src = super.fetchurl {
      url = "mirror://gnu/sed/sed-${version}.tar.xz";
      sha256 = "0fv88bcnraixc8jvpacvxshi30p5x9m7yb8ns1hfv07hmb2ypmnb";
    };
    patches = [ ./gnused/redox.patch ];
  });

  hexyl = whenHost super.hexyl (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
  });

  less = whenHost super.less (attrs: rec {
    patches = [ ./less/redox.patch ];
  });

  libiconv = whenHost super.libiconv (attrs: rec {
    version = "1.15";
    src = super.fetchurl {
      url = "mirror://gnu/libiconv/libiconv-${version}.tar.gz";
      sha256 = "0y1ij745r4p48mxq84rax40p10ln7fc7m243p8k8sia519i3dxfc";
    };
    patches = [ ./libiconv/redox.patch ];
  });

  mesa = whenHost
    (
      if self.stdenv.hostPlatform.isRedox then super.mesa.override {
        enableOSMesa = true;
      } else super.mesa
    )
    (attrs: rec {
      src = self.fetchFromGitLab {
        domain = "gitlab.redox-os.org";
        owner = "redox-os";
        repo = "mesa";
        rev = "18e42435d4e4951fac5b2f02ef701354d9f0cc2f";
        sha256 = "1dvr1x2ckyq4gwvchkmzhpzd3xbj7wc2qcigb6d39i2ikvs2066s";
      };
      nativeBuildInputs = with super.buildPackages; [
        pkgconfig
        autoreconfHook
        intltool
        bison
        flex
        file
        python3Packages.python
        python3Packages.Mako
        zlib
        llvm
      ];
      LDFLAGS = "--static -L${self.buildPackages.gcc.cc}/x86_64-unknown-redox/lib";
      LLVM_LDFLAGS = "--static";
      configureFlags = [
        "--disable-dri"
        "--disable-dri3"
        "--disable-driglx-direct"
        "--disable-egl"
        "--disable-glx"
        "--disable-gbm"
        "--disable-llvm-shared-libs"
        "--disable-shared"
        "--enable-llvm"
        "--enable-gallium-osmesa"
        "--enable-static"
        "--with-gallium-drivers=swrast"
        "--with-platforms=surfaceless"
      ];
      makeFlags = [ "V=1" ];
      # mesonFlags = [
      #   "-Ddri-drivers="
      #   "-Dplatforms=surfaceless,haiku"
      #   "-Ddri3=false"
      #   "-Dgallium-drivers=swrast"
      #   "-Dvulkan-drivers="
      #   "-Dglx=disabled"
      #   # "-Dosmesa=gallium"
      #   "-Degl=false"
      #   "-Dgbm=false"
      # ];
      patches = [ ];
      propagatedBuildInputs = [ ];
      buildInputs = with self; [
        expat
        llvm
        zlib
        openssl
        libiconv
        zlib
      ];
    });

  ncurses = whenHost super.ncurses (attrs: rec {
    name = "ncurses-6.1";
    version = "6.1";
    src = super.fetchurl {
      url = "https://github.com/mirror/ncurses/archive/v6.1.tar.gz";
      sha256 = "0fzsj6rjp08y27ms58nnwhsmlza3mdsk01fk93y62b0fj99wr3mz";
    };

    configureFlags = [
      "--enable-symlinks"
      "--with-manpage-format=normal"
      "--enable-pc-files"
      "--disable-stripping"
      "--disable-db-install"
      "--without-ada"
      "--without-tests"
      "cf_cv_func_mkstemp=yes"
    ];

    postFixup = ''
      cp -r ${super.fetchFromGitHub {
        owner = "sajattack";
        repo = "terminfo";
        rev = "dc5712b13b4a4058ffca1f077167994b1764828a";
        sha256 = "00fpjmaqx6pwmbhi79xg87l7xvadghxzl80vyccvbbn8qvx9xyij";
        }} $out/share
    '';
  });

  # # does not work via overlay
  # llvm = whenTarget super.llvm (attrs: rec {
  #   src = fetchGit {
  #     url = "https://gitlab.redox-os.org/redox-os/llvm-project.git";
  #     ref = "redox";
  #     rev = "bfcfaebc0faa6bcbed692b7997a144de464c4604";
  #   };
  #   unpackPhase = "";
  #   patches = [];
  #   prePatch = ''
  #     for x in $(ls -a | grep -v '^\.\.\?$' | grep -v '^llvm$'); do
  #       rm -rf $x;
  #     done
  #     mv llvm/* .
  #   '';
  #   doCheck = false;
  #   checkTarget = "";
  #   cmakeFlags = with self; [
  #     "-DCMAKE_BUILD_TYPE=Release"
  #     "-DLLVM_INSTALL_UTILS=ON"
  #     "-DLLVM_BUILD_TESTS=OFF" # MODIFIED
  #     "-DLLVM_ENABLE_FFI=ON"
  #     "-DLLVM_ENABLE_RTTI=ON"
  #     "-DLLVM_HOST_TRIPLE=${stdenv.hostPlatform.config}"
  #     "-DLLVM_DEFAULT_TARGET_TRIPLE=${stdenv.hostPlatform.config}"
  #     "-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly"
  #     "-DLLVM_ENABLE_DUMP=ON"
  #     "-DLLVM_BINUTILS_INCDIR=${libbfd.dev}/include"
  #     "-DCMAKE_CROSSCOMPILING=True"
  #     "-DLLVM_TABLEGEN=${buildPackages.llvm_6}/bin/llvm-tblgen"
  #   ];
  # });

  llvm = whenHost
    (
      if self.stdenv.hostPlatform.isRedox then super.llvm_8.override {
        enablePFM = false;
        enableSharedLibraries = false;
        enablePolly = false;
      } else super.llvm
    )
    (attrs: rec {
      src = self.fetchFromGitLab {
        domain = "gitlab.redox-os.org";
        owner = "redox-os";
        repo = "llvm-project";
        rev = "bfcfaebc0faa6bcbed692b7997a144de464c4604";
        sha256 = "0whym4c2a7vrai9cc912f80csn0kqj0ydpvgsw8gzv65fz5lavni";
      };
      unpackPhase = "";
      patches = [ ];
      prePatch = ''
        for x in $(ls -a | grep -v '^\.\.\?$' | grep -v '^llvm$'); do
          rm -rf $x;
        done
        mv llvm/* .
      '';
      doCheck = false;
      dontCheck = true;
      checkTarget = "";
      cmakeFlags = with self; [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_CROSSCOMPILING=True"
        "-DCMAKE_CXX_FLAGS=--std=gnu++11"
        "-DCMAKE_EXE_LINKER_FLAGS=-static"
        # "-DCMAKE_INSTALL_PREFIX=/"
        # "-DCMAKE_SYSTEM_NAME=Generic"
        # "-DCROSS_TOOLCHAIN_FLAGS_NATIVE="-DCMAKE_TOOLCHAIN_FILE=$native"
        "-DLLVM_BUILD_BENCHMARKS=Off"
        "-DLLVM_BUILD_EXAMPLES=Off"
        "-DLLVM_BUILD_TESTS=Off"
        "-DLLVM_BUILD_UTILS=Off"
        # "-DLLVM_DEFAULT_TARGET_TRIPLE="$HOST"
        "-DLLVM_ENABLE_LTO=Off"
        "-DLLVM_ENABLE_RTTI=On"
        "-DLLVM_ENABLE_THREADS=On"
        "-DLLVM_INCLUDE_BENCHMARKS=Off"
        "-DLLVM_INCLUDE_EXAMPLES=Off"
        "-DLLVM_INCLUDE_TESTS=Off"
        "-DLLVM_INCLUDE_UTILS=Off"
        "-DLLVM_OPTIMIZED_TABLEGEN=On"
        "-DLLVM_TABLEGEN=${buildPackages.llvm_8}/bin/llvm-tblgen"
        #"-DLLVM_TABLEGEN="/usr/bin/llvm-tblgen-8"
        # "-DLLVM_TARGET_ARCH="$ARCH"
        "-DLLVM_TARGETS_TO_BUILD=X86"
        "-DLLVM_TOOL_LLVM_COV_BUILD=Off"
        "-DLLVM_TOOL_LLVM_LTO_BUILD=Off"
        "-DLLVM_TOOL_LLVM_LTO2_BUILD=Off"
        "-DLLVM_TOOL_LLVM_PROFDATA_BUILD=Off"
        "-DLLVM_TOOL_LLVM_RTDYLD_BUILD=Off"
        "-DLLVM_TOOL_LLVM_XRAY_BUILD=Off"
        "-DLLVM_TOOL_LLI_BUILD=Off"
        "-DLLVM_TOOL_LTO_BUILD=Off"
        # "-DPYTHON_EXECUTABLE="/usr/bin/python2"
        "-DUNIX=1"
        "-DBUILD_SHARED_LIBS=Off"
        # "-target="$HOST"
        # "-I"$sysroot/include"
        "-Wno-dev"
      ];
    });

  openssl_1_1 = whenHost
    (super.openssl_1_1.override {
      static = self.stdenv.hostPlatform.isRedox;
    })
    (attrs: rec {
      version = "1.1.0";
      src = self.fetchFromGitLab {
        domain = "gitlab.redox-os.org";
        owner = "redox-os";
        repo = "openssl";
        rev = "97449cd8763edcb3cdbd0f2465bdddd5ca9f7818";
        sha256 = "1z6w7ck5wxmyf17yi7y7jd1givxba8rl6hanciz7f159nrdw89fj";
      };

      patches = [ ];
      configureScript = "./Configure no-shared no-dgram redox-x86_64";
      postPatch = ''
        patchShebangs Configure
        substituteInPlace crypto/async/arch/async_posix.h \
          --replace '!defined(__ANDROID__) && !defined(__OpenBSD__)' \
                    '!defined(__ANDROID__) && !defined(__OpenBSD__) && 0'
      '';
    });

  pcre = whenHost super.pcre (attrs: rec {
    name = "pcre-8.42";
    src = self.fetchurl {
      url = "https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.bz2";
      sha256 = "00ckpzlgyr16bnqx8fawa3afjgqxw5yxgs2l081vw23qi1y4pl1c";
    };
    doCheck = false;
    patches = attrs.patches ++ [ ./pcre/redox.patch ];
  });

  perl = whenHost
    (
      if self.stdenv.hostPlatform.isRedox
      then super.perl.override { coreutils = self.pwd; }
      else super.perl
    )
    (attrs: rec {
      version = "5.24.2";
      name = "perl-${version}";
      src = self.fetchurl {
        url = "mirror://cpan/src/5.0/${name}.tar.gz";
        sha256 = "1x4yj814a79lcarwb3ab6bbcb36hvb5n4ph4zg3yb0nabsjfi6v0";
      };
      patches = [ ./perl/redox.patch ./perl/no-sys-dirs.patch ];
      configureFlags = [
        # attrs.configureFlags ++ 
        "--disable-mod=Sys-Syslog,Time-HiRes"
        "--with-libs='m'"
        "--all-static"
        "--no-dynaloader"
        "-Dldflags='-static'"
      ];
      postConfigure = ''
        sed -i "s/^#define Netdb_name_t.*/#define Netdb_name_t const char*/" config.h
        sed -i 's/#define Strerror(e).*$/#define Strerror(e) strerror(e)/' config.h
        sed -i 's/#define L_R_TZSET.*$/#define L_R_TZSET/g' config.h
        echo "#define HAS_VPRINTF" >> config.h
        sed -i 's#.\+tzset();#//tzset();#g' cpan/Time-Piece/Piece.xs
        sed -i 's#.\+tzset();#//tzset();#g' ext/POSIX/POSIX.xs
      '';


      crossVersion = "1.1.9";
      perl-cross-src = self.fetchurl {
        url = "https://github.com/arsv/perl-cross/archive/${crossVersion}.tar.gz";
        sha256 = "06dngygz3j0gxvly646vsh8kr0k22k8rpz7hfnfl806070gwm8lq";
      };
      postUnpack = ''
        unpackFile ${perl-cross-src}
        cp -R perl-cross-${crossVersion}/* perl-${version}/
      '';
    });


  python37 = whenHost
    (super.python37.override (
      if self.stdenv.hostPlatform.isRedox then {
        # openssl = null;
        ncurses = null;
        gdbm = null;
        sqlite = null;
      } else { }
    ))
    (attrs: rec {
      LIBS = "-l:libcrypto.a";

      preConfigure = attrs.preConfigure + ''
        patch -p1 < ${./python3/redox.patch}
      '';

      postConfigure = attrs.postPatch + ''
        sed -i 's|#define HAVE_PTHREAD_KILL 1|/* #undef HAVE_PTHREAD_KILL */|g' pyconfig.h
        sed -i 's|#define HAVE_SCHED_SETSCHEDULER 1|/* #undef HAVE_SCHED_SETSCHEDULER */|g' pyconfig.h
        sed -i 's|#define HAVE_SYS_RESOURCE_H 1|/* #undef HAVE_SYS_RESOURCE_H */|g' pyconfig.h
      '';

      makeFlags = [
        "LDFLAGS=-static"
        "LINKFORSHARED="
      ];

      configureFlags = [
        "--without-ensurepip"
        "--with-system-expat"
        "--with-system-ffi"
        "--disable-ipv6"
        "ac_cv_file__dev_ptmx=no"
        "ac_cv_file__dev_ptc=no"
        "--with-openssl=${self.openssl.dev}"
        "LDFLAGS=-static"
        "--disable-shared"
      ];
    });
  
  relibc = super.relibc.overrideAttrs (attrs: {
    src = super.buildPackages.fetchgit {
      url = "https://gitlab.redox-os.org/redox-os/relibc/";
      rev = "07ec3b6591878f23f3c4be80c26cbfc584abfe43";
      sha256 = "sha256-ztv9uAUVIroZs+9pKx7C2UTn2Tw0RUnaIWRJlUFr/3k=";
      fetchSubmodules = true;
    };
    patches = [ ./relibc/shebang.patch ];
  });

  SDL2 = whenHost
    (
      if self.stdenv.hostPlatform.isRedox then super.SDL2.override {
        x11Support = false;
        # openglSupport = true;
      } else super.SDL2
    )
    (attrs: rec {
      buildInputs = attrs.buildInputs ++ [ self.redoxPkgs.liborbital self.mesa ];
      src = self.fetchFromGitLab {
        domain = "gitlab.redox-os.org";
        owner = "fabiao";
        repo = "sdl2-src";
        rev = "d50d35f09b2aee3ec86b986cc243878549d20791";
        sha256 = "0qlxl1y2wq4rsaqlzmm7db8shng7w9n6qlmy0vdv0sypv8kamgsx";
      };
    });

  sqlite = whenHost super.sqlite (attrs: rec {
    patches = [ ./sqlite3/redox.patch ];
  });

  vim = whenHost super.vim (attrs: rec {
    patches = [ ./vim/redox.patch ];
  });

  xz = whenHost super.xz (attrs: rec {
    name = "xz-5.2.3";
    src = super.fetchurl {
      url = "https://tukaani.org/xz/xz-5.2.3.tar.bz2";
      sha256 = "1ha08wxcldgcl81021x5nhknr47s1p95ljfkka4sqah5w5ns377x";
    };

    patches = [
      ./xz/01-no-poll.patch
      ./xz/02-o_noctty.patch
      ./xz/03-no-signals.patch
    ];
  });

  # rustc = whenTarget super.rustc (attrs: rec {
  #   configureFlags = builtins.filter (x: !builtins.elem x [
  #     "--enable-profiler"
  #   ]) attrs.configureFlags;
  # });

  ion = with self; rustPlatform.buildRustPackage rec {
    pname = "ion";
    version = "unstable-2020-03-22";

    RUSTC_BOOTSTRAP = 1;
    src = super.buildPackages.fetchFromGitLab {
      domain = "gitlab.redox-os.org";
      owner = "redox-os";
      repo = "ion";
      rev = "63d1bf76b6dc27ec9fab80274926738688b6d03e";
      sha256 = "1rp4daf0k2xydb1dayy1xhbjrqwqix3hbd4vzicmdgcwm12qdxkv";
    };

    cargoSha256 = "17pc4v66pvdyxmm9dfgdjyam2549x601l7rflyjaaqr0y58ba9iy";

    meta = with stdenv.lib; {
      description = "Modern system shell with simple (and powerful) syntax";
      homepage = "https://gitlab.redox-os.org/redox-os/ion";
      license = licenses.mit;
      maintainers = with maintainers; [ dywedir ];
      platforms = platforms.all;
    };

    passthru = {
      shellPath = "/bin/ion";
    };
  };

  ########## NEW REDOX PACKAGES (REDOX) ##########

  orbital = self.callPackage ../pkgs/orbital { };

  ########## NEW REDOX PACKAGES (LINUX) ##########

  # redoxiso = self.callPackage ../pkgs/redoxiso {};
  redoxer = self.callPackage ../pkgs/redoxer { };
  redoxfs = self.callPackage ../pkgs/redoxfs { };
  redoxiso = self.callPackage ../pkgs/redoxiso { };

  redox-vm = self.callPackage ../pkgs/redox-vm { };
  redox-vmdisk = self.callPackage ../pkgs/redox-vmdisk { };
  redox-rootfs = self.callPackage ../pkgs/redox-vmdisk/rootfs.nix { };
  redox-kernel = self.callPackage ../pkgs/redox-vmdisk/kernel.nix {
    initfs = self.callPackage ../pkgs/redox-vmdisk/initfs.nix {};
  };

  mergeTrees = name: trees: self.runCommandLocal name {} (''
    mkdir $out
  '' + builtins.concatStringsSep "\n" (builtins.map (v: ''
    cp -R ${self.lib.escapeShellArg v}/* $out
    chmod +w -R $out
  '') trees));

  farmTrees = entries: self.runCommandLocal "tree-farm" {}
  ''mkdir -p $out
    cd $out
    ${self.lib.concatMapStrings (x:
      if (builtins.hasAttr "isDir" x && x.isDir) then ''
        mkdir -p ${self.lib.escapeShellArg x.name}
      '' else ''
          mkdir -p "$(dirname ${self.lib.escapeShellArg x.name})"
          cp -r ${self.lib.escapeShellArg x.path} ${self.lib.escapeShellArg x.name}
      '') entries}
  '';

  # storeTrees = pkgs: let
  #   paths = self.lib.pipe pkgs [
  #     (x: self.closureInfo { rootPaths = x; })
  #     (x: x + /store-paths)
  #     (x: builtins.readFile x)
  #     (x: self.lib.removeSuffix "\n" x)
  #     (x: self.lib.splitString "\n" x)
  #     (x: self.lib.unique x)
  #     (x: map (v: { relative = self.lib.removePrefix "/" v; absolute = v;}) x)
  #   ];
  # in self.runCommandLocal "store-trees" {}(''
  #   mkdir -p $out/nix/store/
  #   mkdir -p $out/bin/
  # '' + builtins.concatStringsSep "\n" (builtins.map (path: ''
  #   ls ${path.absolute}
  #   cp -r ${path.absolute} $out/${path.relative}
  #   cp ${path.absolute}/bin/* $out/bin/ || true
  #   ls $out
  # '') paths));

  storeTrees = bash: pkgsOrig: let
    pkgs = pkgsOrig ++ [ bash ];
    tarballDir = import (self.path + "/nixos/lib/make-system-tarball.nix") {
      inherit (self.buildPackages) stdenv closureInfo pixz;
      contents = [];
      storeContents = map (v: { object = v; symlink = "none"; }) pkgs;
    };
  in self.runCommandLocal "store-trees" {} (''
    tar -xf ${tarballDir}/tarball/*.tar.xz -C .
    mkdir -p $out/bin
    cp -r nix $out
  '' + builtins.concatStringsSep "\n" (builtins.map (pkg: ''
    for bin in ${pkg}/bin/*; do
    SHORT_PATH=$out/bin/$(basename $bin)
    cat << EOF > $SHORT_PATH
    #!/bin/ion

    if test \$len(@args) = 1
      exec $bin
    else
      exec $bin @args[1..]
    end
    
    EOF
    chmod +x $SHORT_PATH
    done
  '') pkgs));

  # exec -a "$0" $(where gcc) "$@"

  ########## NEW REDOX PACKAGES (FOR REDOX ISO BUILDING) ##########

  redoxPkgs =
    let
      redoxBinaryRustPlatform = self.callPackage ../pkgs/redox-binary-rustplatform { };
    in
    {
      drivers = self.callPackage ../pkgs/redox-drivers { };
      init = self.callPackage ../pkgs/redox-init { };
      ipcd = self.callPackage ../pkgs/redox-ipcd { };
      logd = self.callPackage ../pkgs/redox-logd { };
      nulld = self.callPackage ../pkgs/redox-nulld { };
      ptyd = self.callPackage ../pkgs/redox-ptyd { };
      ramfs = self.callPackage ../pkgs/redox-ramfs { };
      randd = self.callPackage ../pkgs/redox-randd { };
      userutils = self.callPackage ../pkgs/redox-userutils { };
      uutils = self.callPackage ../pkgs/redox-uutils { };
      zerod = self.callPackage ../pkgs/redox-zerod { };

      liborbital = self.callPackage ../pkgs/redox-liborbital { };
      installer = self.callPackage ../pkgs/redox-installer { };
    };
}
