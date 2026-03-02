{ config, lib, pkgs, ... }:

{
  imports = [
    ./system
    ./home
  ];
}
