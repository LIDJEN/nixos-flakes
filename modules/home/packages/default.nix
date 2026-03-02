{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.packages;
in
{
  options.modules.home.packages = {
    enable = mkEnableOption "user packages configuration";
    
    # Основные категории пакетов
    utilities = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        htop
        btop
        ripgrep
        fd
        fzf
        jq
        yq
        unzip
        zip
        zoxide
      ];
      description = "Utility packages";
    };
    
    development = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        git
        github-cli
        gcc
        gnumake
      ];
      description = "Development tools";
    };
    
    apps = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        telegram-desktop
        obsidian
        firefox
        thunderbird
        vivaldi
      ];
      description = "Desktop applications";
    };
    
    media = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        mpv
        imv
        pavucontrol
        pulsemixer
      ];
      description = "Media applications";
    };
    
    # Дополнительные пакеты (для ручного добавления)
    extra = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages (add your own here)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = 
      cfg.utilities ++ 
      cfg.development ++ 
      cfg.apps ++ 
      cfg.media ++ 
      cfg.extra;
  };
}
