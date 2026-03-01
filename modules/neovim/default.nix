{ config, lib, pkgs, nix4nvchad, ... }:

with lib;

let
  cfg = config.modules.neovim;
in
{
  options.modules.neovim = {
    enable = mkEnableOption "Neovim with NvChad (via nix4nvchad)";
    
    # Опции для nix4nvchad
    hmActivation = mkOption {
      type = types.bool;
      default = true;  # 👈 true для автоматического управления
      description = "Whether to let home-manager manage NvChad config files";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages (LSP servers, formatters, etc.)";
    };
    
    # Кастомная конфигурация NvChad (опционально)
    chadrc = mkOption {
      type = types.lines;
      default = "";
      description = "Custom chadrc.lua content";
    };
    
    extraPlugins = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra plugins to add to NvChad";
    };
  };

  config = mkIf cfg.enable {
    # Проверка наличия nix4nvchad
    assertions = [
      {
        assertion = nix4nvchad != null;
        message = ''
          nix4nvchad must be passed as a specialArg. 
          Add 'nix4nvchad' to specialArgs in flake.nix
        '';
      }
    ];

    home-manager.users.lidjen = { pkgs, ... }: {
      # 👇 ИМПОРТ МОДУЛЯ NIX4NVCHAD
      imports = [
        nix4nvchad.homeManagerModules.default
      ];
      
      # 👇 ОСНОВНАЯ КОНФИГУРАЦИЯ NVCHAD
      programs.nvchad = {
        enable = true;
        
        # Управление файлами конфигурации
        hm-activation = cfg.hmActivation;
        
        # Отключаем бэкапы при каждой сборке
        backup = false;
        
        # LSP серверы и утилиты (по умолчанию)
        extraPackages = with pkgs; [
          # Языковые серверы
          nil                         # Nix
          nodePackages.bash-language-server
          dockerfile-language-server
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted
          pyright
          rust-analyzer
          lua-language-server
          gopls                       # Go
          
          # Форматтеры
          nixpkgs-fmt
          prettierd
          black
          stylua
          shfmt
          
          # Утилиты для Neovim
          ripgrep
          fd
          tree-sitter
          gcc                         # Для компиляции плагинов
        ] ++ cfg.extraPackages;
        
        # 👇 Кастомный chadrc (если нужен)
        extraConfig = mkIf (cfg.chadrc != "") ''
          -- Custom chadrc configuration
          ${cfg.chadrc}
        '';
        
        # 👇 Кастомные плагины
        # extraPlugins = cfg.extraPlugins;
      };
      
      # Алиасы для удобства
      home.shellAliases = {
        nvim-update = "nvim --headless -c 'Lazy! sync' -c 'qa'";
        nvim-clean = "rm -rf ~/.local/share/nvim ~/.local/state/nvim";
        nvim-rebuild = "home-manager switch --flake ~/Flake";
      };
      
      # Переменные окружения
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
    
    # Информационное сообщение
    warnings = mkIf (!cfg.hmActivation) [
      ''
        ⚠️  hmActivation = false means home-manager won't manage your NvChad config.
        Make sure you have NvChad installed manually:
          git clone https://github.com/NvChad/starter ~/.config/nvim
      ''
    ];
  };
}
