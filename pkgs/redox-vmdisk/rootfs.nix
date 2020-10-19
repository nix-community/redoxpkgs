{ callPackage, mergeTrees, farmTrees, storeTrees
, pkgsCross
, redoxPkgs
, ion
, relibc
}:

let
  initfs = callPackage ./initfs.nix { };
  # kernel = callPackage ./kernel.nix { inherit initfs; };

  bootloader = callPackage ./bootloader.nix { };

in
mergeTrees "redox-vm-rootfs" (with redoxPkgs; [
  drivers
  ion
  ipcd
  logd
  ptyd
  relibc
  userutils
  uutils
  (farmTrees [
    { name = "kernel"; path = pkgsCross.x86_64-unknown-redox.redox-kernel; }
    { name = "bootloader"; path = bootloader; }

    { name = "home/user"; isDir = true; }
    { name = "root"; isDir = true; }

    {
      name = "etc/init.d/00_base";
      path = builtins.toFile "00_base" ''
        ipcd
        logd
        ptyd
        pcid /etc/pcid.d/
      '';
    }
    {
      name = "etc/init.d/30_console";
      path = builtins.toFile "30_console" ''
        getty debug: -J
      '';
    }
    {
      name = "etc/passwd";
      path = builtins.toFile "passwd" ''
        root;0;0;root;file:/root;file:/bin/ion
        user;1;1;user;file:/home/user;file:/bin/ion
      '';
    }
    {
      name = "etc/shadow";
      path = builtins.toFile "shadow" ''
        root;
        user;
      '';
    }
  ])
  (storeTrees pkgsCross.x86_64-unknown-redox.bash (with pkgsCross.x86_64-unknown-redox; [
    cowsay
  ]))
])
