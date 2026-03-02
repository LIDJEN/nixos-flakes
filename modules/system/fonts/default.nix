{ config, lib, pkgs, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.modules.fonts;
  stable = nixpkgs-stable.legacyPackages.${pkgs.system};
in
{
  options.modules.fonts = {
    enable = mkEnableOption "Fonts configuration";
    
    withNerdFonts = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    fonts.packages = with stable; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ] ++ lib.optionals cfg.withNerdFonts [
      stable.nerdfonts.jetbrains-mono
    ];

    fonts.fontconfig.enable = true;
    fonts.fontDir.enable = true;
  };
}
