{
  description = "ASUS ROG Flow X13 GV302X - NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    
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

    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-hardware, nixpkgs-stable, lanzaboote, home-manager, nix4nvchad, zapret-discord-youtube, ... }: {
    nixosConfigurations.rog-flow-x13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nix4nvchad;
	inherit nixpkgs-stable;
	inherit zapret-discord-youtube;
      };
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
	./modules/neovim
	./modules/zapret
        {
          # Fonts
          fonts.fontDir.enable = true;
          fonts.packages = with nixpkgs-stable.legacyPackages.x86_64-linux; [
            jetbrains-mono
            noto-fonts
	    noto-fonts-cjk-sans
            noto-fonts-color-emoji
          ];
        }
      ];
    };
  };
}
