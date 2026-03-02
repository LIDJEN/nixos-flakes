{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.niri;
in
{
  options.modules.home.niri = {
    enable = mkEnableOption "user niri config";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      fuzzel
      mako
      swaylock
      grim
      slurp
      wl-clipboard
      swayidle
      xwayland-satellite
    ];

    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000;
        anchor = "top-right";
        background-color = "#1e1e2eff";
        text-color = "#cdd6f4";
        border-color = "#cba6f7";
        border-radius = 8;
        border-size = 2;
        font = "JetBrainsMono Nerd Font 12";
      };
    };

    services.swayidle = {
      enable = true;
      events = {
        "before-sleep" = "${pkgs.swaylock}/bin/swaylock -f";
        "lock" = "${pkgs.swaylock}/bin/swaylock -f";
      };
      timeouts = [
        { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
    };

    programs.swaylock = {
      enable = true;
      settings = {
        clock = true;
        indicator = true;
        show-failed-attempts = true;
        font = "JetBrainsMono Nerd Font 12";
        line-color = "1e1e2e";
        ring-color = "cba6f7";
        key-hl-color = "89b4fa";
        text-color = "cdd6f4";
        inside-color = "1e1e2e";
      };
    };

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font 12";
          lines = 15;
          width = 40;
          background = "1e1e2ecc";
          text-color = "cdd6f4";
          match-color = "89b4fa";
          selection-color = "313244";
          border-color = "cba6f7";
          border-width = 2;
        };
      };
    };

    programs.waybar = {
      enable = true;
      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font", sans-serif;
          font-size: 13px;
        }
      '';
      settings = [{
        layer = "top";
        position = "top";
        modules-left = ["niri/workspaces"];
        modules-center = ["clock"];
        modules-right = ["pulseaudio" "network" "battery" "tray"];
        
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "";
            focused = "";
            urgent = "";
          };
        };
      }];
    };

    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };
}
