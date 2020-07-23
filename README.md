# Redoxpkgs

Redoxpkgs is an overlay to allow using Nix to cross-compile packages to [Redox](https://redox-os.org).

Usage for example package `hexyl` (note: long build time!)
```bash
nix-build . -A hexyl
```

#### Packages

Known working:

* `hexyl`
* `binutils`

Known kinda working:

* `vim`

#### Cross-compilers

* `buildPackages.gcc`
* `buildPackages.rustc`
