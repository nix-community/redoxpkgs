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
  
in {
  b3sum = whenHost super.b3sum (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
  });

  bat = whenHost super.bat (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
  });

  bash = whenHost super.bash (attrs: rec {
    patchFlags = [];
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
      "--disable-gdb" "--disable-nls"
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

  # coreutils = if self.stdenv.hostPlatform.isRedox
  #   then self.callPackage ./coreutils {}
  #   else super.coreutils;
  
  rcoreutils = self.callPackage ./coreutils {};

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

  ion = whenHost super.ion (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
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
    configureFlags = builtins.filter (x: !builtins.elem x [
      "--with-pic"
      "--enable-cxx"
    ]) attrs.configureFlags;
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

  openssl_1_1 = whenHost (super.openssl_1_1.override {
    static = self.stdenv.hostPlatform.isRedox;
  }) (attrs: rec {
    version = "1.1.0";
    src = self.fetchFromGitLab {
      domain = "gitlab.redox-os.org";
      owner = "redox-os";
      repo = "openssl";
      rev = "97449cd8763edcb3cdbd0f2465bdddd5ca9f7818";
      sha256 = "1z6w7ck5wxmyf17yi7y7jd1givxba8rl6hanciz7f159nrdw89fj";
    };

    patches = [];
    configureScript = "./Configure no-shared no-dgram redox-x86_64";
  });

  perl = whenHost super.perl (attrs: rec {
    version = "5.24.2";
    name = "perl-${version}";
    src = self.fetchurl {
      url = "mirror://cpan/src/5.0/${name}.tar.gz";
      sha256 = "1x4yj814a79lcarwb3ab6bbcb36hvb5n4ph4zg3yb0nabsjfi6v0";
    };
    patches = [ ./perl/redox.patch ./perl/no-sys-dirs.patch ];
    configureFlags = [ # attrs.configureFlags ++ 
      "--disable-mod=Sys-Syslog,Time-HiRes" "--with-libs='m'"
      "--all-static" "--no-dynaloader"
      "-Dldflags='-static'"
    ];
    postConfigure = ''
      sed -i "s/^#define Netdb_name_t.*/#define Netdb_name_t const char*/" config.h
      sed -i 's/#define Strerror(e).*$/#define Strerror(e) strerror(e)/' config.h
      sed -i 's/#define L_R_TZSET.*$/#define L_R_TZSET/g' config.h
      echo "#define HAS_VPRINTF" >> config.h
      echo "#####################################"
      ls
      pwd
      ls cpan
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


  python37 = whenHost (super.python37.override (if self.stdenv.hostPlatform.isRedox then {
    # openssl = null;
    ncurses = null;
    gdbm = null;
    sqlite = null;
  } else {})) (attrs: rec {
    LIBS = "-l:libcrypto.a";

    postConfigure = attrs.postPatch + ''
      sed -i 's|#define HAVE_PTHREAD_KILL 1|/* #undef HAVE_PTHREAD_KILL */|g' pyconfig.h
      sed -i 's|#define HAVE_SCHED_SETSCHEDULER 1|/* #undef HAVE_SCHED_SETSCHEDULER */|g' pyconfig.h
      sed -i 's|#define HAVE_SYS_RESOURCE_H 1|/* #undef HAVE_SYS_RESOURCE_H */|g' pyconfig.h
    '';

    preConfigure = attrs.preConfigure + ''
      patch -p1 < ${./python3/redox.patch}
    '';
    
    configureFlags = [
      "--without-ensurepip"
      "--with-system-expat"
      "--with-system-ffi"
      "--disable-ipv6"
      "ac_cv_file__dev_ptmx=no"
      "ac_cv_file__dev_ptc=no"
      "--with-openssl=${self.openssl.dev}"
      "LDFLAGS=-static"
    ];
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

  ########## NEW REDOX PACKAGES (REDOX) ##########

  orbital = self.callPackage ../pkgs/orbital {};

  ########## NEW REDOX PACKAGES (LINUX) ##########

  # redoxiso = self.callPackage ../pkgs/redoxiso {};
  redoxer  = self.callPackage ../pkgs/redoxer {};
  redoxfs  = self.callPackage ../pkgs/redoxfs {};

  ########## NEW REDOX PACKAGES (FOR REDOX ISO BUILDING) ##########

  

  # redoxPkgs = let
  #   redoxBinaryRustPlatform = self.callPackage ../pkgs/redox-binary-rustplatform {};
  # in {
  #   drivers   = self.callPackage ../pkgs/redox-drivers {
  #     # rustPlatform = redoxBinaryRustPlatform;
  #   };
  #   init      = self.callPackage ../pkgs/redox-init {};
  #   installer = self.callPackage ../pkgs/redox-installer {};
  #   nulld     = self.callPackage ../pkgs/redox-nulld {};
  #   ramfs     = self.callPackage ../pkgs/redox-ramfs {};
  #   randd     = self.callPackage ../pkgs/redox-randd {};
  # };
}
