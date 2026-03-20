{
  description = "Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.hmoens = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          nixvim.homeManagerModules.nixvim
        ];
        extraSpecialArgs = {
          username = "hmoens";
          homeDirectory = "/home/hmoens";
          userEmail = "hendrik@moens.io";
        };
      };

      homeConfigurations.hmoens-work = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          nixvim.homeManagerModules.nixvim
        ];
        extraSpecialArgs = {
          username = "hendrik.moens@openchip.com";
          homeDirectory = "/home/hendrik.moens@openchip.com";
          userEmail = "hendrik.moens@openchip.com";
        };
      };
    };
}
