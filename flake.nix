{
  description = "JCM Clipboard Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      jcm = pkgs.callPackage ./nix/default.nix {};
      default = self.packages.${system}.jcm;
    });

    homeManagerModules.jcm = import ./nix/hm-module.nix;
    homeManagerModules.default = self.homeManagerModules.jcm;
  };
}
