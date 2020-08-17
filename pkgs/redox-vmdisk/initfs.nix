{ mergeTrees, farmTrees
, redoxPkgs
, redoxfs
}:

mergeTrees "redox-vm-initfs" (with redoxPkgs; [
  drivers
  init
  nulld
  ramfs
  randd
  redoxfs
  zerod
  (farmTrees [{
    name = "etc/init.rc";
    path = builtins.toFile "" ''
      export PATH /bin
      export TMPDIR /tmp
      nulld
      zerod
      randd
      vesad T T G
      ps2d us
      ramfs logging
      pcid /etc/pcid/initfs.toml
      redoxfs --uuid $REDOXFS_UUID file $REDOXFS_BLOCK
      cd file:
      export PATH file:/bin
      run.d /etc/init.d
    '';
  }])
])
