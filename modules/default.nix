{ config, lib, pkgs, ... }:

{
  # Импортируем все модули (они могут содержать и NixOS, и home-manager части)
  imports = [
    ./fonts
    ./niri
    ./neovim
    ./zapret
  ];
}
