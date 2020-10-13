{ stdenv, fetchFromGitLab, rustPlatform, fuse, pkgconfig }:

let bins = [
  "base32"
  "base64"
  "basename"
  "cat"
  "chmod"
  "cksum"
  "comm"
  "cp"
  "cut"
  "date"
  "dircolors"
  "dirname"
  "echo"
  "env"
  "expand"
  "expr"
  "factor"
  "false"
  "fmt"
  "fold"
  "hashsum"
  "head"
  "install"
  "join"
  "link"
  "ln"
  "ls"
  "mkdir"
  "mktemp"
  "more"
  "mv"
  "nl"
  "od"
  "paste"
  "printenv"
  "printf"
  "ptx"
  "pwd"
  "readlink"
  "realpath"
  "relpath"
  "rm"
  "rmdir"
  "seq"
  "shred"
  "shuf"
  "sleep"
  "sort"
  "split"
  "sum"
  "tac"
  "tail"
  "tee"
  "test"
  "tr"
  "true"
  "truncate"
  "tsort"
  "uname"
  "unexpand"
  "uniq"
  "wc"
  "yes"
]; in rustPlatform.buildRustPackage rec {
  pname = "redox-uutils";
  version = "latest";

  src = fetchFromGitLab {
    domain = "gitlab.redox-os.org";
    owner = "redox-os";
    repo = "uutils";
    rev = "4170d593b3d94a204b085ac9f10c565bd70d8191";
    sha256 = "043b5g4qy2m7npbjv4bzs3nxpk927z0svdq66wggpxvd9jidkpfc";
  };

  cargoBuildFlags = [
    "--no-default-features --features redox"
  ] ++ map (v: "-p ${v}") bins;

  doCheck = false;

  cargoSha256 = "07zbxl4407sca5jqgimvhp74rib3pksg3ml9ym0gcb7i7c3lxp8d";

  outputs = [ "out" "dev" ];

  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    homepage = "https://gitlab.redox-os.org/redox-os/uutils";
    maintainers = with maintainers; [ aaronjanse ];
    platforms = platforms.redox;
  };
}
