{ config, lib, pkgs, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.modules.home.fonts;  
  stable = nixpkgs-stable.legacyPackages.${pkgs.system};
in
{
  options.modules.home.fonts = {
    enable = mkEnableOption "user fonts configuration";
    
    withNerdFonts = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install Nerd Fonts";
    };
    
    monospaceFont = mkOption {
      type = types.str;
      default = "JetBrainsMono Nerd Font";
      description = "Default monospace font family";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with stable; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ cfg.monospaceFont "JetBrains Mono" ];
      };
    };
  };
}
