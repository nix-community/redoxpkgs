let
  nixpkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/64a9b4b7a341c7f423932bf8f4366f07654060e6.tar.gz";
    sha256 = "0fhamzazlnf78chlcxg84q3kbjmg10srvp0vmn4kkmy449cjhw5j";
  });
  overlay = import ./overlay;
in

with (nixpkgs {
    overlays = [ overlay ];
    config.allowUnsupportedSystem = true;
}); pkgs
