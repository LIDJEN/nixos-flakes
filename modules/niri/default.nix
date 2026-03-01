{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.niri;
  userName = "lidjen";
  
  # Путь к конфигу
  niriConfigFile = ./config.kdl;
in
{
  options.modules.niri = {
    enable = mkEnableOption "niri scrollable-tiling Wayland compositor";
  };

  config = mkIf cfg.enable {
    # Включаем niri через официальный модуль [citation:2]
    programs.niri.enable = true;
    
    # Порталы для Wayland (важно для скриншотов и экранов) [citation:8]
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome  # Нужен для niri [citation:2]
        xdg-desktop-portal-gtk
      ];
    };
    
    # Polkit для авторизации [citation:2]
    security.polkit.enable = true;
    security.pam.services.swaylock = {};  # Для блокировки экрана [citation:2]
    
    # Gnome keyring для хранения паролей [citation:8]
    services.gnome.gnome-keyring.enable = true;
    
    # Необходимые системные пакеты
    environment.systemPackages = with pkgs; [
      xwayland-satellite  # Для запуска X11 приложений [citation:8]
      swaybg              # Для установки обоев
      libnotify           # Для уведомлений
      brightnessctl       # Управление яркостью (полезно на ноутбуке)
      playerctl           # Управление медиа
      networkmanagerapplet # Трей для сети
    ];
    
    # Пользовательские настройки через home-manager
    home-manager.users.${userName} = { pkgs, ... }: {
      # Основные пакеты для окружения niri [citation:2]
      home.packages = with pkgs; [
        # Лаунчер и статус бар
        fuzzel
        waybar
        
        # Утилиты для Wayland
        grim                # Скриншоты
        slurp               # Выбор области для скриншота
        wl-clipboard        # Буфер обмена Wayland
        wlr-randr           # Управление мониторами
      ];
      
      # Конфигурационные файлы [citation:2]
      xdg.configFile = {
        "niri/config.kdl".source = niriConfigFile;
      };
      
      # Сервисы для полноценного DE [citation:2]
      services.mako = {
        enable = true;
        defaultTimeout = 5000;
        anchor = "top-right";
        backgroundColor = "#1e1e2eff";
        textColor = "#cdd6f4";
        borderColor = "#cba6f7";
        borderRadius = 8;
        borderSize = 2;
      };
      
      services.swayidle = {
        enable = true;
        events = [
          { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
          { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
        ];
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
          screenshots = false;
          font = "Monospace 12";
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
            font = "Monospace 12";
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
        settings = [{
          layer = "top";
          position = "top";
          height = 30;
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
          
          clock = {
            format = "{:%H:%M} ";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          
          pulseaudio = {
            format = "{volume}% {icon}";
            format-muted = "";
            format-icons = ["" ""];
            on-click = "pavucontrol";
          };
          
          network = {
            format-wifi = "";
            format-ethernet = "";
            format-disconnected = "";
            on-click = "nm-connection-editor";
          };
          
          battery = {
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
            format-charging = "{capacity}% ";
          };
          
          tray = {
            icon-size = 20;
            spacing = 5;
          };
        }];
      };
    };
  };
}
