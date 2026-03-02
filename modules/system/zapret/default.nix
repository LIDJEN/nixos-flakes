{ config, lib, pkgs, zapret-discord-youtube, ... }:

with lib;

let
  cfg = config.modules.system.zapret;
in
{
  # Импорт внешнего модуля
  imports = [
    zapret-discord-youtube.nixosModules.default
  ];

  options.modules.system.zapret = {
    enable = mkEnableOption "system zapret service";
    
    # Основные настройки
    config = mkOption {
      type = types.str;
      default = "general(ALT)";
      description = "Zapret strategy (general, general(ALT), general (SIMPLE FAKE))";
    };
    
    gameFilter = mkOption {
      type = types.enum [ "null" "all" "tcp" "udp" ];
      default = "null";
      description = "Game filter mode (null = off, all = TCP+UDP, tcp, udp)";
    };
    
    # Списки доменов
    listGeneral = mkOption {
      type = types.listOf types.str;
      default = [
        "discord.com"
        "discord.gg"
        "discordapp.com"
        "youtube.com"
        "ytimg.com"
        "googlevideo.com"
      ];
      description = "Domains to block/unblock";
    };
    
    listExclude = mkOption {
      type = types.listOf types.str;
      default = [ "ubisoft.com" "origin.com" ];
      description = "Domains to exclude from filtering";
    };
    
    # IP-адреса
    ipsetAll = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "IP addresses/networks to filter";
    };
    
    ipsetExclude = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "IP addresses/networks to exclude";
    };
  };

  config = mkIf cfg.enable {
    services.zapret-discord-youtube = {
      enable = true;
      configName = cfg.config;
      gameFilter = cfg.gameFilter;
      listGeneral = cfg.listGeneral;
      listExclude = cfg.listExclude;
      ipsetAll = cfg.ipsetAll;
      ipsetExclude = cfg.ipsetExclude;
    };
  };
}
