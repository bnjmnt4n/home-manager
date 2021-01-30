{
  description = "Home Manager for Nix";

  outputs = { self, nixpkgs }: rec {
    nixosModules.home-manager = import ./nixos;
    nixosModule = self.nixosModules.home-manager;

    darwinModules.home-manager = import ./nix-darwin;
    darwinModule = self.darwinModules.home-manager;

    lib = {
      hm = import ./modules/lib { lib = nixpkgs.lib; };
      homeManagerConfiguration = { configuration, system, homeDirectory
        , username, stateVersion ? "20.09", extraSpecialArgs ? { }
        , pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
        , check ? true }@args:
        assert nixpkgs.lib.versionAtLeast stateVersion "20.09";

        import ./modules {
          inherit pkgs check;

          configuration = { ... }: {
            imports = [ configuration ];
            home = { inherit stateVersion homeDirectory username; };
            nixpkgs = { inherit (pkgs) config overlays; };
          };

          extraSpecialArgs = extraSpecialArgs;
        };
    };
  };
}
