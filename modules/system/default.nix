{ config, lib, pkgs, ... }:

{
  imports = [
    ./fonts
    ./niri
    ./zapret
  ];

  # options.modules.system = {
  #   fonts.enable = lib.mkEnableOption "system fonts";
  #   niri.enable = lib.mkEnableOption "system niri support";
  #   zapret.enable = lib.mkEnableOption "system zapret service";
  # };
}
