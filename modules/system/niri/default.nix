{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.niri;
in
{
  options.modules.system.niri = {
    enable = mkEnableOption "system niri support";
  };

  config = mkIf cfg.enable {
    programs.niri.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    security.polkit.enable = true;
    security.pam.services.swaylock = {};
  };
}
