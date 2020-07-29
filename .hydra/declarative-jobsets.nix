{ nixpkgs, declInput }:

let
  pkgs = import nixpkgs {};

  desc = {
    master = {
      description = "Build master branch of Redoxpkgs";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "expr";
      nixexprpath = "default.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      hidden = false;
      type = 0;
      inputs = {
        expr = {
          value = "https://github.com/nix-community/redoxpkgs master";
          type = "git";
          emailresponsible = false;
        };
      };
    };
  };

in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
  '';
}
