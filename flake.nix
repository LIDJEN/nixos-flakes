{
  description = "ASUS ROG Flow X13 GV302X - NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
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

  outputs = { self, nixpkgs, nixpkgs-stable, nixos-hardware, lanzaboote, home-manager, nix4nvchad, zapret-discord-youtube, ... }: {
    
    # ---------- NIXOS КОНФИГУРАЦИЯ (основная) ----------
    nixosConfigurations.rog-flow-x13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = {
        inherit nix4nvchad;
        inherit nixpkgs-stable;
        inherit zapret-discord-youtube;
      };
      
      modules = [
        nixos-hardware.nixosModules.asus-flow-gv302x-amdgpu
        ./configuration.nix
        ./hardware-configuration.nix
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        
        # Главный модуль, который импортирует все остальные
        ./modules
        
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit nix4nvchad;
            inherit nixpkgs-stable;
            inherit zapret-discord-youtube;
          };
          home-manager.users.lidjen = import ./home.nix;
        }
      ];
    };
    
    # ---------- ОТДЕЛЬНАЯ HOME-MANAGER КОНФИГУРАЦИЯ ----------
    homeConfigurations = {
      lidjen = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        
        # extraSpecialArgs для передачи inputs
        extraSpecialArgs = {
          inherit nix4nvchad;
          inherit nixpkgs-stable;
          inherit zapret-discord-youtube;
        };
        
        # Модули home-manager
        modules = [
          # Основной home.nix
          ./home.nix
          
          nix4nvchad.homeManagerModules.default

          ./modules/fonts
          ./modules/niri
          ./modules/neovim
        ];
      };
    };
  };
}
