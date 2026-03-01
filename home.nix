# /etc/nixos/home.nix - Home Manager configuration for lidjen
{ pkgs, config, lib, ... }:
let
  # ---------------------------------------------------------
  # ПЕРЕМЕННЫЕ (легко менять в одном месте)
  # ---------------------------------------------------------
  flakeDir = "/home/lidjen/Flake";
  systemName = "rog-flow-x13";
  userName = "lidjen";
  
  # Собираем пути из переменных
  systemFlake = "${flakeDir}#${systemName}";
  userFlake = "${flakeDir}#${userName}";
  
in
{
  # ---------------------------------------------------------
  # 📦 USER PACKAGES
  # ---------------------------------------------------------
  home.packages = with pkgs; [
    # Sys
    home-manager

    # Niri
    xwayland-satellite
    swaybg
    waybar
    fuzzel
    mako
    swaylock
    swayidle
    udiskie

    # Development
    git
    
    # Shell
    zsh
    starship
    kitty
    
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


  # Desktop env
  services.swayidle = {
    enable = true;
    defaultTimeout = 5000;
    anchor = "top-right";

    events = [
      { event = "before-sleep"; command = "$pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
    ];
  };

  programs.waybar = {
    enable = true;
    # add config
  };

  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;

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
  # VARIABLES
  # ---------------------------------------------------------
  home.sessionVariables = {
    HOME_MANAGER_CONFIG = "${flakeDir}";
    EDITOR = "nvim";
    VISUAL = "nvim";

  };


  # ---------------------------------------------------------
  # SHELL ALIASES
  # ---------------------------------------------------------
  home.shellAliases = {
    # Home-manager aliases
    hm = "home-manager";
    hms = "home-manager switch --flake ${userFlake}";
    hme = "home-manager edit --flake ${userFlake}";
    hmg = "home-manager generations";
    
    # System rebuild aliases
    nrs = "sudo nixos-rebuild switch --flake ${systemFlake}";
    nrt = "sudo nixos-rebuild test --flake ${systemFlake}";
    nrb = "sudo nixos-rebuild build --flake ${systemFlake}";
    nr = "sudo nixos-rebuild switch --flake ${systemFlake}";  # короткая версия
    
    # Additional useful aliases
    flake = "cd ${flakeDir}";  # быстро перейти в flake директорию
    flake-ls = "ls -la ${flakeDir}";
    
    # Nix maintenance
    ngc = "sudo nix-collect-garbage -d && nix-collect-garbage -d";  # очистка мусора
    nup = "nix flake update ${flakeDir}";  # обновление flake.lock
    ns = "nix search nixpkgs";  # поиск пакетов

    # Поиск и информация
    nix-search = "nix search nixpkgs";
    nix-info = "nix info nixpkgs";
    nix-ls = "nix profile list";
    
    # История поколений
    hm-history = "home-manager generations";
    nix-history = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    
    # Откат
    hm-rollback = "home-manager generations | fzf --header 'Выберите поколение для отката' | awk '{print $1}' | xargs home-manager switch --flake ${userFlake} --rollback";

    niri-reload = "niri msg action quit";
    niri-edit = "nvim ${flakeDir}/modules/niri/config.kdl";
    niri-version = "niri --version";
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      bold_font = "auto";
      bold_italic_font = "auto";
    };
  };

  # ---------------------------------------------------------
  # 🧹 HOME STATE
  # ---------------------------------------------------------
  home.stateVersion = "24.05";
}
