{ config, lib, pkgs, nix4nvchad, ... }:

with lib;

let
  cfg = config.modules.home.neovim;
in
{
  options.modules.home.neovim = {
    enable = mkEnableOption "Neovim with NvChad";
    
    hmActivation = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to let home-manager manage NvChad config files";
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra LSP servers and tools";
    };
    
    chadrc = mkOption {
      type = types.lines;
      default = "";
      description = "Custom NvChad configuration";
    };
  };

  config = mkIf cfg.enable {
    # LSP серверы и утилиты
    home.packages = with pkgs; [
      nil
      nodePackages.bash-language-server
      dockerfile-language-server
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      pyright
      rust-analyzer
      lua-language-server
      gopls
      nixpkgs-fmt
      prettierd
      black
      stylua
      shfmt
      ripgrep
      fd
      tree-sitter
      gcc
    ] ++ cfg.extraPackages;

    # Neovim алиасы
    home.shellAliases = {
      nvim-update = "nvim --headless -c 'Lazy! sync' -c 'qa'";
      nvim-clean = "rm -rf ~/.local/share/nvim ~/.local/state/nvim";
      vi = "nvim";
      vim = "nvim";
    };

    # Переменные окружения
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
