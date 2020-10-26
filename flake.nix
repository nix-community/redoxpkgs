{
  description = "Use Nix to cross-compile packages to Redox";

  inputs = {
    nixpkgs.url = "github:aaronjanse/nixpkgs/redox";
  };

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "i686-linux" "aarch64-linux" ];
  in {
    overlay = import ./overlay;

    legacyPackages = forAllSystems (system: import nixpkgs {
      inherit system;
      overlays = [ self.overlay ];
      config.allowUnsupportedSystem = true;
    });

    packages = forAllSystems (system: let
      pkgs = self.legacyPackages."${system}";
    in {
      redox-vm = pkgs.redox-vm;
      redox-vm2 = pkgs.redox-vm.withPackages (rpkgs: [
        (pkgs.storeTrees pkgs.pkgsCross.x86_64-unknown-redox.bash (with pkgs.pkgsCross.x86_64-unknown-redox; [
          python37
        ]))
      ]);
    });
    defaultPackage = forAllSystems (system: self.packages."${system}".redox-vm);

    apps = forAllSystems (system: {
      redox-vm = {
        type = "app";
        program = "${self.packages."${system}".redox-vm}/vm.sh";
      };
    });
    defaultApp = forAllSystems (system: self.apps."${system}".redox-vm);
  };
}
