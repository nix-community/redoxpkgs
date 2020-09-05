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

To install a compiled package onto Redox, copy the /nix/store path at the end of nix-build's stdout onto your Redox filesystem:

```
redoxfs harddrive.bin /mnt
mkdir -p /mnt/nix/store
cp -r /nix/store/mfhmfarn90g71ysxi7z6iaz07dwjj166-cowsay-3.03+dfsg2-x86_64-unknown-redox /mnt/nix/store
```

Unmount your filesystem, launch QEMU, and enjoy:
```
(redox) $ echo 'hi' | /nix/store/mfhmfarn90g71ysxi7z6iaz07dwjj166-cowsay-3.03+dfsg2-x86_64-unknown-redox/bin/cowsay
```
