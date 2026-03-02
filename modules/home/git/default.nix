# /home/lidjen/Flake/modules/home/git/default.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.git;
  
  secretsFile = "${flakeDir}/secrets/git.nix";
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
    
    extraConfig = mkOption {
      type = types.attrsOf types.anything;
      default = {};
    };
    
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      userName = if cfg.userName != null 
                 then cfg.userName 
                 else secrets.gitUserName or "CHANGE_ME";
      
      userEmail = if cfg.userEmail != null 
                  then cfg.userEmail 
                  else secrets.gitUserEmail or "CHANGE_ME@example.com";
      
      aliases = cfg.aliases;
      
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        color.ui = "auto";
      } // cfg.extraConfig;
    };

    # Git алиасы для shell
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
