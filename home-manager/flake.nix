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

      workHome = "/home/hendrik.moens@openchip.com";
      isWorkMachine = builtins.pathExists "/home/hendrik.moens@openchip.com";

      mkConfig =
        args:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            nixvim.homeModules.nixvim
          ];
          extraSpecialArgs = args;
        };
    in
    {
      homeConfigurations.default =
        if isWorkMachine then
          mkConfig {
            username = "hendrik.moens@openchip.com";
            homeDirectory = workHome;
            userEmail = "hendrik.moens@openchip.com";
          }
        else
          mkConfig {
            username = "hmoens";
            homeDirectory = "/home/hmoens";
            userEmail = "hendrik@moens.io";
          };

      homeConfigurations.hmoens = mkConfig {
        username = "hmoens";
        homeDirectory = "/home/hmoens";
        userEmail = "hendrik@moens.io";
      };

      homeConfigurations.hmoens-work = mkConfig {
        username = "hendrik.moens@openchip.com";
        homeDirectory = workHome;
        userEmail = "hendrik.moens@openchip.com";
      };
    };
}
