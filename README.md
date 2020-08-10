# Redoxpkgs

Redoxpkgs is an overlay to allow using Nix to cross-compile packages to [Redox](https://redox-os.org).

Usage for example package `hexyl` (note: long build time!)
```bash
nix-build . -A pkgsCross.x86_64-unknown-redox.hexyl
```

To build redox-related packages for your system (rather than cross compiling):
```bash
nix-build . -A origPkgs.redoxfs
```

#### Cross-compiled packages

Known working:

* `hexyl`
* `binutils`
* `bash`
* `cowsay`
* `perl`

Known kinda working:

* `vim`
* `python37`

These compile but not yet have been tested:

* `openssl`
* `xz`
* `less`
* `sl`
* `pipes`

These compile but don't run:

* `python37`

#### Cross-compilers

* `buildPackages.gcc`
* `buildPackages.rustc`

#### Redox-related packages for local system

These compile but have not yet have been tested:

* `redoxfs`
* `redoxer`
