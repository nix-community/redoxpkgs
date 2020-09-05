# Redoxpkgs

Redoxpkgs is an overlay to allow using Nix to cross-compile packages to [Redox](https://redox-os.org).

#### Installation

Install [Nix](https://nixos.org/), a declarative build system:
```
curl -L https://nixos.org/nix/install | sh
```

Install [Cachix](https://cachix.org/), a build cache system:
```
nix-env -iA cachix -f https://cachix.org/api/v1/install
```

Enable the [Nix Community](https://nix-community.org/) cache: 
```
cachix use nix-community
```

#### Usage

To compile `cowsay`:
```
nix-build . -A pkgsCross.x86_64-unknown-redox.cowsay
```

You can also try `hexyl` or `sl`.
