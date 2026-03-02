{ config, lib, pkgs, zapret-discord-youtube, ... }:

with lib;

let
  cfg = config.modules.zapret;
in
{
  config = mkIf cfg.enable {
    services.zapret-discord-youtube = {
      enable = true;
      config = "general(ALT)";
    };
  };
}

