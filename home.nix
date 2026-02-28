# /etc/nixos/home.nix - Home Manager configuration for lidjen
{ pkgs, config, lib, ... }:

{
  # ---------------------------------------------------------
  # 📦 USER PACKAGES
  # ---------------------------------------------------------
  home.packages = with pkgs; [
    # Development
    git
    
    # Shell
    zsh
    starship
    
    # Utilities
    htop
    btop
    ripgrep
    fd
    fzf
    
    # Apps
    telegram-desktop
    typst
    obsidian

  ];

  # ---------------------------------------------------------
  # ⌨️ SHELL: ZSH + STARSHIP
  # ---------------------------------------------------------
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "fzf" ];
    };
  };
  
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # ---------------------------------------------------------
  # 🎮 NVIM (NvChad will be installed manually)
  # ---------------------------------------------------------
  programs.neovim ={
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # ---------------------------------------------------------
  # 🎨 GIT CONFIG
  # ---------------------------------------------------------
  programs.git = {
    enable = true;
    userName = "LIDJEN";
    userEmail = "andrewsawa21@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };


  # ---------------------------------------------------------
  # 🧹 HOME STATE
  # ---------------------------------------------------------
  home.stateVersion = "24.05";
}
