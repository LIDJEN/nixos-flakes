{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.neovim;
  installScript = ./install-nvchad.sh;
in
{
  options.modules.neovim = {
    enable = mkEnableOption "Neovim with NvChad";
    
    withNvChad = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install NvChad";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages for Neovim (LSP servers, formatters, etc.)";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.lidjen = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Основные утилиты для Neovim
        ripgrep
        fd
        tree-sitter
        
        # LSP серверы
        nil
        nodePackages.bash-language-server
        dockerfile-language-server
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted
        pyright
        rust-analyzer
        lua-language-server
        
        # Форматтеры
        nixpkgs-fmt
        prettierd
        black
        stylua
      ] ++ cfg.extraPackages;
      
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        
        # Базовая конфигурация
        extraConfig = ''
          " Путь для плагинов NvChad
          set runtimepath^=~/.config/nvim
        '';
      };
      
      home.file.".local/bin/nvchad-install" = mkIf cfg.withNvChad {
        source = installScript;
	executable = true;
      };

      home.file.".config/nvim/.keep".text = ''
        # NvChad будет установлен вручную
        # Запусти: git clone https://github.com/NvChad/starter ~/.config/nvim
      '';
    };
    
    # Добавляем сообщение пользователю
    warnings = mkIf cfg.withNvChad [
      "NvChad не установлен автоматически. После пересборки выполни:"
      "  git clone https://github.com/NvChad/starter ~/.config/nvim"
      "  nvim  # для установки плагинов"
    ];
  };
}
