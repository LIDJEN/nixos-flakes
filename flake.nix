{
  description = "ASUS ROG Flow X13 GV302X - NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixos-hardware, lanzaboote, home-manager, nix4nvchad, ... }: {
    nixosConfigurations.rog-flow-x13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nix4nvchad; };
      modules = [
        nixos-hardware.nixosModules.asus-flow-gv302x-amdgpu
        # nixos-hardware.nixosModules.asus-flow-gv302x-nvidia
        ./configuration.nix
        ./hardware-configuration.nix
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lidjen = import ./home.nix;
	  home-manager.extraSpecialArgs = { inherit nix4nvchad; };
        }
	./modules/niri
      ];
    };
  };
}
