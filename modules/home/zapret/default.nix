{ config, lib, pkgs, zapret-discord-youtube, ... }:

with lib;

let
  cfg = config.modules.home.zapret;
in
{
  imports = [
    zapret-discord-youtube.nixosModules.default
  ];

  options.modules.zapret = {
    enable = mkEnableOption "zapret for Discord/Youtube bypass";

    config = mkOption {
      type = types.str;
      default = "general(ALT2)";
      description = "Zapret config to use (general, general(ALT), general (SIMPLE FAKE))";
    };
    
    gameFilter = mkOption {
      type = types.enum [ "null" "all" "tcp" "udp" ];
      default = "null";
      description = "Game filter mode";
    };

    listGeneral = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom domains for liist-general-user.txt";
    };

    listExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Domains to exclude";
    };
    
    ipsetAll = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "IP addresses for ipset-all.txt";
    };
    
    ipsetExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "IP addresses to exclude";
    };
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      zapret-status = "systemctl status zapret-discord-youtube";
      zapret-logs = "journalctl -u zapret-discord-youtube -f";
      zapret-restart = "sudo systemctl restart zapret-discord-youtube";
    };
    services.zapret-discord-youtube = {
      enable = true;
      config = cfg.config;
      gameFilter = cfg.gameFilter;
      listGeneral = cfg.listGeneral;
      listExclude = cfg.listExclude;
      ipsetAll = cfg.ipsetAll;
      ipsetExclude = cfg.ipsetExclude;
    };
  };
}

