# /home/lidjen/Flake/home.nix
{ pkgs, config, lib, nix4nvchad, nixpkgs-stable, zapret-discord-youtube, ... }:

let
  flakeDir = "/home/lidjen/Flake";
  systemName = "rog-flow-x13";
  userName = "lidjen";
  
  systemFlake = "${flakeDir}#${systemName}";
  userFlake = "${flakeDir}#${userName}";
in
{
  # ---------------------------------------------------------
  # ИМПОРТ МОДУЛЕЙ
  # ---------------------------------------------------------
  imports = [
    ./modules/home
  ];

  # ---------------------------------------------------------
  # ВКЛЮЧЕНИЕ МОДУЛЕЙ
  # ---------------------------------------------------------
  modules.home = {
    packages.enable = true;
    fonts.enable = true;
    git.enable = true;
    niri.enable = true;
    neovim.enable = true;
    zapret.enable = true;
    shell.enable = true;
  };

  # ---------------------------------------------------------
  # НАСТРОЙКИ МОДУЛЕЙ
  # ---------------------------------------------------------
  
  # Пакеты
  modules.home.packages = {
    extra = with pkgs; [
      typst
      home-manager
      udiskie
      # Добавляй свои пакеты сюда
    ];
  };

  # Шрифты
  modules.home.fonts = {
    monospaceFont = "JetBrainsMono Nerd Font";
    withNerdFonts = true;
  };

  # Git (данные из secrets/git.nix)
  modules.home.git = {
    enable = true;
    # Если нужно переопределить (приоритет выше secrets)
    # userName = "LIDJEN";
    # userEmail = "other@example.com";
    
    extraConfig = {
      # Дополнительные настройки git
      # url."git@github.com:" = {
      #   insteadOf = "https://github.com/";
      # };
    };
  };

  # Niri
  modules.home.niri = {
    enable = true;
    # можно добавить опции
  };

  # Zapret
  modules.home.zapret.enable = true;

  # Shell (общие алиасы)
  modules.home.shell = {
    enable = true;
    extraAliases = {
      # Свои алиасы
      update-all = "nix flake update ~/Flake && sudo nixos-rebuild switch --flake ~/Flake#rog-flow-x13 && home-manager switch --flake ~/Flake#lidjen";
      clean-all = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    };
    extraEnvVars = {
      DOTFILES = flakeDir;
    };
    functions = ''
      nix-search() {
        nix search nixpkgs "$1" | grep -A 5 -B 5 "$1"
      }
      
      nix-size() {
        nix path-info -Sh "/run/current-system/sw/bin/$1" 2>/dev/null || nix path-info -Sh "$1"
      }
    '';
  };

  # ---------------------------------------------------------
  # Kitty (пока не вынесен в модуль)
  # ---------------------------------------------------------
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      theme = "Catppuccin-Mocha";
    };
  };

  # ---------------------------------------------------------
  # 🧹 HOME STATE
  # ---------------------------------------------------------
  home.stateVersion = "24.05";
}
