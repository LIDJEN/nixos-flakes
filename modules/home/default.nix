# /home/lidjen/Flake/modules/home/default.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./packages
    ./fonts
    ./git
    ./niri
    ./neovim
    ./zapret
    ./shell
  ];

  options.modules.home = {
    packages.enable = lib.mkEnableOption "user packages";
    fonts.enable = lib.mkEnableOption "user fonts config";
    git.enable = lib.mkEnableOption "git configuration";
    niri.enable = lib.mkEnableOption "user niri config";
    neovim.enable = lib.mkEnableOption "neovim with nvchad";
    zapret.enable = lib.mkEnableOption "user zapret aliases";
    shell.enable = lib.mkEnableOption "shell configuration";
  };
}
