# /home/lidjen/Flake/modules/home/shell/default.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.shell;
  flakeDir = "/home/lidjen/Flake";
  systemName = "rog-flow-x13";
  userName = "lidjen";
  
  systemFlake = "${flakeDir}#${systemName}";
  userFlake = "${flakeDir}#${userName}";
in
{
  options.modules.home.shell = {
    enable = mkEnableOption "shell configuration";
    
    extraAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
    
    extraEnvVars = mkOption {
      type = types.attrsOf types.str;
      default = {};
    };
    
    functions = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      
      autosuggestion = {
        enable = true;
        strategy = [ "history" ];
      };
      
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "fzf" "docker" "history" "colored-man-pages" ];
      };
      
      initExtra = ''
        # Environment variables
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "export ${name}=${value}") cfg.extraEnvVars)}
        
        # Custom functions
        ${cfg.functions}
        
        # Starship prompt
        eval "$(starship init zsh)"
      '';
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        nix_shell = {
          symbol = "❄️ ";
          format = "via [$symbol$state]($style) ";
        };
      };
    };

    # Общие алиасы home.shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Listing
      ll = "ls -l";
      la = "ls -A";
      lt = "ls -lt";
      
      # System
      c = "clear";
      h = "history";
      md = "mkdir -p";
      
      # Nix
      nix-gc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nix-search = "nix search nixpkgs";
      
      # Flake navigation
      flake = "cd ${flakeDir}";
      flake-modules = "cd ${flakeDir}/modules";
      flake-home = "cd ${flakeDir}/modules/home";
      flake-system = "cd ${flakeDir}/modules/system";
      
      # Edit configs
      hm-edit = "nvim ${flakeDir}/home.nix";
      sys-edit = "nvim ${flakeDir}/configuration.nix";
      flake-edit = "nvim ${flakeDir}/flake.nix";
      
      # Quick module access
      hm-shell = "nvim ${flakeDir}/modules/home/shell/default.nix";
      hm-git = "nvim ${flakeDir}/modules/home/git/default.nix";
      hm-niri = "nvim ${flakeDir}/modules/home/niri/default.nix";
      hm-nvim = "nvim ${flakeDir}/modules/home/neovim/default.nix";
      hm-zapret = "nvim ${flakeDir}/modules/home/zapret/default.nix";
      hm-packages = "nvim ${flakeDir}/modules/home/packages/default.nix";
      hm-fonts = "nvim ${flakeDir}/modules/home/fonts/default.nix";
    } // cfg.extraAliases;
  };
}
