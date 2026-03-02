{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.katvan;
  
  katvanAppImage = pkgs.fetchurl {
    url = "https://github.com/IgKh/katvan/releases/download/v0.12.0/Katvan-0.12.0-x86_64.AppImage";
    hash = "sha256-hJMsJt+6EFDPRDk3IQub0y727TgGcThT+aTPtlzgT5U=";
  };
  
  katvanPackage = pkgs.runCommand "katvan" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    cp ${katvanAppImage} $out/bin/katvan
    chmod +x $out/bin/katvan
    
    # Добавляем typst в PATH
    wrapProgram $out/bin/katvan \
      --prefix PATH : ${lib.makeBinPath [ pkgs.typst ]}
  '';
in
{
  options.modules.home.katvan = {
    enable = mkEnableOption "Katvan Typst editor";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      katvanPackage
      pkgs.typst
      pkgs.fuse3
    ];
    
    home.shellAliases = {
      katvan = "katvan";
    };
  };
}
