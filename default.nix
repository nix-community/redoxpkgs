let
  nixpkgsParent = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/64a9b4b7a341c7f423932bf8f4366f07654060e6.tar.gz";
    sha256 = "0fhamzazlnf78chlcxg84q3kbjmg10srvp0vmn4kkmy449cjhw5j";
  }) {};
  nixpkgs = nixpkgsParent.fetchFromGitHub {
    repo = "nixpkgs";
    owner = "aaronjanse";
    rev = "a133f31b92aaa055475b904cca144404fb75f925";
    sha256 = "19kzrrl9glfz9hgfc6drqb7r6gw12q6d6vglxrbb69lrpqqgjzm8";
  };
  overlay = import ./overlay;
in
with (import nixpkgs {
  overlays = [ overlay ];
  config.allowUnsupportedSystem = true;
}); pkgs
