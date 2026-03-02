{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.git;
  
  secretsFile = /home/lidjen/Flake/secrets/git.nix;
  secrets = if builtins.pathExists secretsFile 
            then import secretsFile 
            else {
              gitUserName = "CHANGE_ME";
              gitUserEmail = "CHANGE_ME@example.com";
            };
in
{
  options.modules.home.git = {
    enable = mkEnableOption "Git configuration";
    
    userName = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    
    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    
    extraSettings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      # 👇 НОВЫЙ СИНТАКСИС - ВСЁ ВНУТРИ settings
      settings = {
        user = {
          name = if cfg.userName != null 
                 then cfg.userName 
                 else secrets.gitUserName or "CHANGE_ME";
          
          email = if cfg.userEmail != null 
                  then cfg.userEmail 
                  else secrets.gitUserEmail or "CHANGE_ME@example.com";
        };
        
        init = {
          defaultBranch = "main";
        };
        
        pull = {
          rebase = true;
        };
        
        push = {
          autoSetupRemote = true;
        };
        
        core = {
          editor = "nvim";
        };
        
        color = {
          ui = "auto";
        };
        
        # 👇 АЛИАСЫ ТОЖЕ ЗДЕСЬ
        alias = {
          co = "checkout";
          br = "branch";
          ci = "commit";
          st = "status";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
        };
      } // cfg.extraSettings;
    };

    # Git алиасы для shell (оставляем для быстрого доступа)
    home.shellAliases = {
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gpl = "git pull";
    };
  };
}
