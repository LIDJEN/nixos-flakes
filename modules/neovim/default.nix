{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.neovim;
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
    # Пакеты для Neovim и LSP
    home-manager.users.lidjen = { pkgs, ... }: {
      home.packages = with pkgs; [
        # Основные утилиты для Neovim
        ripgrep
        fd
        tree-sitter
        
        # LSP серверы (по умолчанию)
        nil                          # Nix LSP
        nodePackages.bash-language-server
        dockerfile-language-server
        nodePackages.typescript-language-server
        nodePackages.vscode-langservers-extracted  # HTML, CSS, JSON
        pyright                      # Python LSP
        rust-analyzer                 # Rust LSP
        lua-language-server           # Lua LSP
        
        # Форматтеры
        nixpkgs-fmt
        prettierd
        black                        # Python formatter
        stylua                        # Lua formatter
        
        # Дополнительные пакеты из опции
      ] ++ cfg.extraPackages;
      
      # Базовая конфигурация Neovim
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        
        # Если NvChad включён, не переопределяем конфиг здесь
        # (NvChad установится отдельно через git)
      };
      
      # Установка NvChad если нужно
      home.activation = mkIf cfg.withNvChad {
        installNvChad = lib.hm.dag.entryAfter ["writeBoundary"] ''
          if [ ! -d "$HOME/.config/nvim" ]; then
            $DRY_RUN_CMD git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
            $DRY_RUN_CMD nvim --headload "+Lazy! sync" +qa
            $VERBOSE_ECHO "NvChad installed"
          else
            $DRY_RUN_CMD nvim --headload "+Lazy! sync" +qa
            $VERBOSE_ECHO "NvChad already installed, updated plugins"
          fi
        '';
      };
      
      # Символическая ссылка для кастомной конфигурации (опционально)
      xdg.configFile."nvim/lua/custom".source = mkIf cfg.withNvChad ./custom;
    };
  };
}
