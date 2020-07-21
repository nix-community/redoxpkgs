# Redoxpkgs

Redoxpkgs is an overlay to allow using Nix to cross-compile packages to [Redox](https://redox-os.org).

Usage for example package `hexyl` (note: long build time!)
```bash
nix-build . -A hexyl
```

#### Working packages

This is a non-exhaustive list of packages that are known to be work on Redox. 

* `hexyl`
* `binutils`

#### Working cross-compilers

* `buildPackages.gcc`
* `buildPackages.rustc`
