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

in {
  b3sum = whenHost super.b3sum (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
    meta.platforms = super.lib.platforms.all;
  });

  bash = whenHost super.bash (attrs: rec {
    patchFlags = [];
    patches = [ ./bash/redox.patch ];
  });

  binutils = whenHost super.binutils (attrs: rec {
    nativeBuildInputs = attrs.nativeBuildInputs ++ (with self; [ texinfo flex ]);
    configureFlags = attrs.configureFlags ++ [
      "--disable-gdb" "--disable-nls"
    ];
    src = fetchGit {
      url = "https://gitlab.redox-os.org/redox-os/binutils-gdb";
      rev = "692afe7cc2d41134d08e5c487ddad125d5aaec5e";
    };
    patches = [
      ./binutils/deterministic.patch
      ./binutils/disambiguate-arm-targets.patch
      ./binutils/always-search-rpath.patch
    ];
  });

  curl = whenHost super.curl (attrs: rec {
    src = fetchGit {
      url = "https://gitlab.redox-os.org/redox-os/curl";
      rev = "1c5963a79ba69bc332865dfbfc2cddc7e545dc80";
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

  ion  = super.ion.overrideAttrs (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
    meta.platforms = attrs.meta.platforms ++ super.lib.platforms.redox;
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

  hexyl = super.hexyl.overrideAttrs (attrs: rec {
    RUSTC_BOOTSTRAP = 1;
    meta.platforms = attrs.meta.platforms ++ super.lib.platforms.redox;
  });

  libiconv = whenHost super.libiconv (attrs: rec {
    version = "1.15";
    src = super.fetchurl {
      url = "mirror://gnu/libiconv/libiconv-${version}.tar.gz";
      sha256 = "0y1ij745r4p48mxq84rax40p10ln7fc7m243p8k8sia519i3dxfc";
    };
    patches = [ ./libiconv/redox.patch ];
  });

  libpfm = whenHost super.libpfm (attrs: rec {
    meta.platforms = attrs ++ super.lib.platforms.redox;
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

  openssl = whenHost super.openssl (attrs: rec {
    src = fetchGit {
      url = "https://gitlab.redox-os.org/redox-os/openssl";
      ref = "redox";
      rev = "97449cd8763edcb3cdbd0f2465bdddd5ca9f7818";
    };
  });

  redoxCoreutils = self.callPackage ./coreutils {};

  # rustc = whenTarget super.rustc (attrs: rec {
  #   configureFlags = builtins.filter (x: !builtins.elem x [
  #     "--enable-profiler"
  #   ]) attrs.configureFlags;
  # });
}
